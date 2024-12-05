#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root."
    exit 1
fi

# Function to install udp-custom
install_udp_custom() {
    cd
    rm -rf /root/udp
    mkdir -p /root/udp

    # Change to time GMT+3
    echo "Changing time to GMT+3"
    ln -fs /usr/share/zoneinfo/Africa/Kampala /etc/localtime

    # Install udp-custom
    echo "Downloading udp-custom"
    wget "https://github.com/Humran13/UDP-Custom/raw/main/udp-custom-linux-amd64" -O /root/udp/udp-custom
    chmod +x /root/udp/udp-custom

    # Download default config
    echo "Downloading default config"
    wget "https://raw.githubusercontent.com/Humran13/UDP-Custom/main/config.json" -O /root/udp/config.json
    chmod 644 /root/udp/config.json

    # Create the systemd service file
    if [ -z "$1" ]; then
        cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team
After=network.target

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=multi-user.target
EOF
    else
        cat <<EOF > /etc/systemd/system/udp-custom.service
[Unit]
Description=UDP Custom by ePro Dev. Team
After=network.target

[Service]
User=root
Type=simple
ExecStart=/root/udp/udp-custom server -exclude $1
WorkingDirectory=/root/udp/
Restart=always
RestartSec=2s

[Install]
WantedBy=multi-user.target
EOF
    fi

    # Reload systemd to apply the new service
    echo "Reloading systemd daemon"
    systemctl daemon-reload

    # Start and enable the udp-custom service
    echo "Starting udp-custom service"
    systemctl start udp-custom

    echo "Enabling udp-custom service to start on boot"
    systemctl enable udp-custom

    echo "Installation completed. Rebooting system..."
    reboot
}

# Function to uninstall udp-custom
uninstall_udp_custom() {
    echo "Stopping udp-custom service..."
    systemctl stop udp-custom

    echo "Disabling udp-custom service..."
    systemctl disable udp-custom

    echo "Removing udp-custom service file..."
    rm -f /etc/systemd/system/udp-custom.service

    echo "Reloading systemd daemon..."
    systemctl daemon-reload

    echo "Removing /root/udp directory..."
    rm -rf /root/udp

    echo "Uninstallation completed successfully."
}

# Function to add a user (example function)
add_user() {
    read -p "Enter the username: " username
    read -p "Enter the password: " password
    # Example logic to add a user, adapt as necessary
    echo "User $username with password $password added."
}

# Main menu
while true; do
    echo "Please select an option:"
    echo "1. Install udp-custom"
    echo "2. Uninstall udp-custom"
    echo "3. Add user"
    echo "4. Exit"
    read -p "Enter your choice: " choice

    case $choice in
        1)
            install_udp_custom
            ;;
        2)
            uninstall_udp_custom
            ;;
        3)
            add_user
            ;;
        4)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done
