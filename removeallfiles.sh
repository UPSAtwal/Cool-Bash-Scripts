#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run as root."
    exit 1
fi

if [ -z "$1" ]; then
    echo "No username supplied"
    exit 1
fi

username=$1

# Check if user exists
if id "$username" >/dev/null 2>&1; then
    echo "User exists"
    if [ "$(id -u "$username")" -le 1000 ]; then # le = less than or equal to
        echo "Cannot remove files of system/first user"
        exit 1
    fi
    
    # Remove all files and directories owned by the user in their home directory
    echo "Removing files and directories for user: $username"
    find "/home/$username" -user "$username" -exec rm -rf {} \;
    
    echo "Files and directories removed for user: $username"
else
    echo "User does not exist"
    exit 1
fi
