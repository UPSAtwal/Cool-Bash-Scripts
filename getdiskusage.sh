#!/bin/bash
# script needs to be run as root

# Path: scripts/getdiskusage.sh
# getdiskusage.sh <username>
# gets disk usage for the user's home directory and all users in megabytes

# TODO: Shift to quota based disk usage calculation. Looping through /etc/passwd is inefficient. Or create a file/DB with all users created in the frontend/UI to ONLY get their disk usage and update it every time a user is added or deleted.

# ! Outputs from this script should not be used in calculations. It is not accurate.

set -eo pipefail # see - http://redsymbol.net/articles/unofficial-bash-strict-mode/

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

## * Redundant check. 'User exists or not' check is done in PHP code.
if ! id "$username" >>/dev/null 2>&1; then # redirect stderr to /dev/null in append mode
    echo "User does not exist"
    exit 1
fi

# Exclude system users (UID <= 1000)
if [ "$(id -u "$username")" -le 1000 ]; then
    echo "Cannot get disk usage for system user or user with UID 1000."
    exit 1
fi

# TODO: check if max depth changes speed of du command

# Get disk usage for the user's home directory in MiB (Mebibyte)
userusageinmb=$(du -sk /home/"$username" | awk '{printf "%.3f : MiB : %s\n", $1/1024, $2}')

# Get disk usage for all users in MiB (Mebibyte)
# ! NOTE: this assumes that all users have their home directory in /home/ and no unnecessary directories are present in /home/
alluserusageinmb=$(du -sk /home/ | awk '{printf "%.3f : MiB : %s\n", $1/1024, $2}')

# Get available disk space in MiB (Mebibyte)
availablespaceinmb=$(df -m / | awk '{print $4}' | tail -n 1)

# Print user and their disk usage
# echo "Disk Usage of "
echo "$username : $userusageinmb"
echo  "all : $alluserusageinmb"
echo "available : $availablespaceinmb : MiB : "
exit 0
