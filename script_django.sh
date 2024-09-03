# Last update before install
sudo apt update && sudo apt upgrade -y

# Virtual environment setup
sudo apt install python3-venv -y

# Folder creation for group of apps
mkdir -p django-apps
cd django-apps

# Virtual environment creation with name
python3 -m venv env

# Virtual environment activation
source env/bin/activate

# Django installation via pip
pip install django

# Django startproject command
django-admin startproject gymManageSys
cd gymManageSys

# App start referred to main (main is the app name)
python3 manage.py startapp main

cd ..
cd ..
deactivate

# Install PostgreSQL
sudo apt install curl ca-certificates -y
sudo mkdir -p /usr/share/postgresql-common/pgdg
sudo curl -o /usr/share/postgresql-common/pgdg/apt.postgresql.org.asc --fail https://www.postgresql.org/media/keys/ACCC4CF8.asc
sudo sh -c 'echo "deb [signed-by=/usr/share/postgresql-common/pgdg/apt.postgresql.org.asc] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
sudo apt update
sudo apt install postgresql -y
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Install pgAdmin4
#sudo apt update
#sudo apt install curl -y
#curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub | sudo gpg --dearmor -o /usr/share/keyrings/packages-pgadmin-org.gpg
#sudo sh -c 'echo "deb [signed-by=/usr/share/keyrings/packages-pgadmin-org.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/$(lsb_release -cs) pgadmin4 main" > /etc/apt/sources.list.d/pgadmin4.list'
#sudo apt update
#sudo apt install pgadmin4 -y

# Install psycopg2-binary (install with env active)


sudo apt install build-essential libpq-dev -y
cd
cd django-apps
source env/bin/activate
pip install psycopg2-binary





# settings.py Inline Python3 code: credentials for postgres in DATABASES, and add application in INSTALLED_APPS
python3 <<END
import os
import re

def update_settings(settings_path):
    with open(settings_path, 'r') as file:
        content = file.read()
    
    # Update DATABASES
    new_db_config = """
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.postgresql_psycopg2',
        'NAME':'db1',                        
        'USER':'rodrigo',
        'PASSWORD':'huachalomo',
        'HOST': '127.0.0.1',
        'PORT':5432,
    }

"""
    content = re.sub(r"DATABASES = \{.*?\}", new_db_config, content, flags=re.DOTALL)
    
    # Update INSTALLED_APPS
    new_apps = """
INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'main',
]
"""
    content = re.sub(r"INSTALLED_APPS = \[.*?\]", new_apps, content, flags=re.DOTALL)
    
    with open(settings_path, 'w') as file:
        file.write(content)

# Get the current user's home directory
home_directory = os.environ['HOME']

# Construct the file path
settings_path = f"{home_directory}/django-apps/gymManageSys/gymManageSys/settings.py"

# Call the function with the dynamically constructed path
update_settings(settings_path)

END


# Database name, user, and password
db_name="db1"
db_user="rodrigo"
db_password="huachalomo"

# Connect to PostgreSQL as the postgres user and execute commands
sudo -i -u postgres psql <<EOF
CREATE DATABASE "${db_name}";
CREATE USER "${db_user}" WITH PASSWORD '${db_password}';
GRANT ALL PRIVILEGES ON DATABASE "${db_name}" TO "${db_user}";  

\c "${db_name}";

GRANT CREATE ON SCHEMA public TO "${db_user}";
\q
EOF


pwd
# nota: estamos en django-apps parados
cd gymManageSys
cd main


#--------------------LAST script test UNTIL THIS POINT ---------------------------
# In models.py, write kind of a test to ensure Django is connected to Postgresql

# Step 1: Write new content to models.py
cat <<EOF > models.py
from django.db import models

class Service(models.Model):
    title = models.CharField(max_length=150)
    detail = models.TextField()
EOF

cd ..
cd ..

# Step 2: Activate the virtual environment
source env/bin/activate

# Step 3: Navigate to the correct directory
cd gymManageSys

# Step 4: Run Django management commands
python3 manage.py makemigrations
python3 manage.py migrate

pwd

cd gymManageSys

# edit gymManageSys/gymManageSys/urls.py, add include and 2nd path
cat <<EOF > urls.py
from django.contrib import admin
from django.urls import path, include
urlpatterns = [
    path('admin/', admin.site.urls),
    path('', include('main.urls')),
]
EOF


cd ..
cd main
pwd
# create /main/urls.py
touch urls.py
cat <<EOF > urls.py
from django.urls import path
from . import views
urlpatterns=[
	path('',views.home,)
]
EOF


# create /main/views.py
touch views.py
cat <<EOF > views.py
from django.shortcuts import render
# Home Page
def home(request):
    return render(request, 'home.html')
EOF



mkdir templates
cd templates
touch home.html
touch base.html


cat <<EOF > home.html
{% load static %}
<html>
<head>
	<meta charset="utf-8">
	<title></title>
	<link href="{% static 'bootstrap.min.css' %}" rel="stylesheet">
	<script src="{% static 'bundle.min.js' %}"></script>
</head>
<body>
	<div class="container">
		<h1>Home Page<h1>
	</div>
</body>
</html> 
EOF

#Create 'static' folder under main and put inside the two bootstrap files
cd ..
mkdir static
cd static
# Download bootstrap files from repo
curl -O https://raw.githubusercontent.com/nautilusdata/bootstuff/main/bootstrap.bundle.min.js
curl -O https://raw.githubusercontent.com/nautilusdata/bootstuff/main/bootstrap.min.css

# back to user base dir
cd
cd django-apps
# enviro activation
source env/bin/activate
cd gymManageSys
# run server
python3 manage.py runserver
#bye
exit 0
