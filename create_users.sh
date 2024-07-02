#!/bin/bash

# Log file
LOG_FILE="/var/log/user_management.log"

# Secure password file
PASSWORD_FILE="/var/secure/user_passwords.txt"

# Function to log messages to LOG_FILE
log_message() {
    local log_message="$1"
    echo "$(date +"%Y-%m-%d %H:%M:%S") - ${log_message}" >> "$LOG_FILE"
}

# Check if script is run as root
if [ "$(id -u)" -ne 0 ]; then
    echo "This script must be run as root" >&2
    exit 1
fi

# Check if the number of arguments provided is not exactly 1
if [ "$#" -ne 1 ]; then
    echo "Usage: $0 <input_file>"
    exit 1
fi

input_file="$1"

# Check if input file exists
if [ ! -f "$input_file" ]; then
    echo "Input file $input_file not found"
    exit 1
fi

# Reading input file line by line
while IFS=';' read -r username groups; do
    # Skip empty lines or lines starting with #
    if [ -z "$username" ] || [[ "$username" == "#"* ]]; then
        continue
    fi
    
    # Create user with home directory and personal group
    useradd -m -s /bin/bash "$username" -c "Employee Account" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        log_message "Failed to create user: $username"
        continue
    else
        log_message "Created user: $username"
    fi

    # Generate random password
    password=$(openssl rand -base64 12)
    
    # Set password for the user
    echo "$username:$password" | chpasswd
    if [ $? -ne 0 ]; then
        log_message "Failed to set password for user: $username"
    else
        log_message "Set password for user: $username"
        # Save password securely
        echo "$username:$password" >> "$PASSWORD_FILE"
    fi

    # Create personal group with the same name as the username
    groupadd "$username" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        log_message "Failed to create group: $username"
    else
        log_message "Created group: $username"
    fi

    # Add user to their personal group
    usermod -a -G "$username" "$username" >> "$LOG_FILE" 2>&1
    if [ $? -ne 0 ]; then
        log_message "Failed to add user $username to group $username"
    else
        log_message "Added user $username to group $username"
    fi

    # Add user to additional groups specified in input file
    IFS=',' read -ra additional_groups <<< "$groups"
    for group in "${additional_groups[@]}"; do
        groupadd "$group" >> "$LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
            log_message "Failed to create group: $group"
        else
            log_message "Created group: $group"
        fi
        usermod -a -G "$group" "$username" >> "$LOG_FILE" 2>&1
        if [ $? -ne 0 ]; then
            log_message "Failed to add user $username to group $group"
        else
            log_message "Added user $username to group $group"
        fi
    done

    # Set ownership and permissions for home directory
    home_dir=$(eval echo ~$username)
    chown -R "$username:$username" "$home_dir"
    chmod 700 "$home_dir"
    
done < "$input_file"

echo "User creation process completed. Check $LOG_FILE for details."


