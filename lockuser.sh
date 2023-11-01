#!/bin/bash
# script needs to be run as root
# check if user already exists then checks id of user, and dont allow to lock first user i.e. lock only users with id > 1000 & lock user

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

# check if user already exists & lock user
if id "$username" >/dev/null 2>&1; then
    echo "User exists"
    if [ "$(id -u "$username")" -le 1000 ]; then # le = less than or equal to
        echo "Cannot lock system/ first user"
        exit 1
    elif [ "$(id -u "$username")" -gt 1000 ]; then
        echo "Locking user account"
        sudo usermod -L "$username"
    fi
else
    echo "User does not exist"
    exit 1
fi

echo "SFTP Account locked for $username"
exit 0
