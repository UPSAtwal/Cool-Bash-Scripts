#!/bin/bash
# script needs to be run as root
# check if user already exists then checks id of user, and dont allow to unlock/ change first user i.e. unlock/ change only users with id > 1000 & unlock user

set -eo pipefail # see - http://redsymbol.net/articles/unofficial-bash-strict-mode/

if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run as root."
    exit 1
fi

if [ -z "$1" ]; then
    echo "No username supplied"
    exit 1
fi

username=$1

# check if user already exists & unlock user
if id "$username" >/dev/null 2>&1; then
    echo "User exists"
    if [ "$(id -u "$username")" -le 1000 ]; then # le = less than or equal to
        echo "Cannot change first user"
        exit 1
    elif [ "$(id -u "$username")" -gt 1000 ]; then
        echo "Unlocking user account"
        sudo usermod -U "$username"
    fi
else
    echo "User does not exist"
    exit 1
fi

echo "SFTP Account unlocked for $username"
exit 0
