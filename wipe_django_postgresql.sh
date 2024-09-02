#!/bin/bash

# Function to uninstall Django
uninstall_django() {
    echo "Uninstalling Django..."

    # If installed via pip
    if command -v pip3 &> /dev/null; then
        echo "Uninstalling Django via pip..."
        pip3 uninstall -y django
    fi

    # If installed via system package manager
    if dpkg -l | grep -q python3-django; then
        echo "Uninstalling Django via apt..."
        sudo apt-get remove --purge -y python3-django
    fi

    echo "Django uninstallation complete."
}

# Function to wipe Django-related files
wipe_django_files() {
    echo "Wiping Django-related files..."

    # Remove common Django project directories
    rm -rf ~/my_django_project
    rm -rf ~/django_projects

    echo "Django-related files wiped."
}

# Function to uninstall PostgreSQL
uninstall_postgresql() {
    echo "Uninstalling PostgreSQL..."

    # Stop PostgreSQL service
    sudo systemctl stop postgresql

    # Remove PostgreSQL packages
    sudo apt-get remove --purge -y postgresql postgresql-* 

    # Remove PostgreSQL data directory and configuration files
    sudo rm -rf /var/lib/postgresql
    sudo rm -rf /etc/postgresql
    sudo rm -rf /var/log/postgresql
    sudo rm -rf /var/run/postgresql

    echo "PostgreSQL uninstallation complete."
}

# Function to wipe PostgreSQL data
wipe_postgresql_data() {
    echo "Wiping PostgreSQL data..."

    # Removing PostgreSQL user and groups
    sudo deluser postgres
    sudo delgroup postgres

    echo "PostgreSQL data wiped."
}

# Main script execution
echo "Starting the uninstallation and data wipe process..."

uninstall_django
wipe_django_files
uninstall_postgresql
wipe_postgresql_data

echo "Uninstallation and data wipe complete."

