#!/bin/bash
# script needs to be run as root
# changeuserpassword.sh <username> <password>
# change user password

set -eo pipefail # see - http://redsymbol.net/articles/unofficial-bash-strict-mode/

if [ "$EUID" -ne 0 ]; then
    echo "This script needs to be run as root."
    exit 1
fi

if [ -z "$1" ]; then
    echo "No username supplied"
    exit 1
fi

if [ -z "$2" ]; then
    echo "No password supplied"
    exit 1
fi

username=$1
password=$2

#check if user already exists
if ! id "$username" >>/dev/null 2>&1; then # redirect stderr to /dev/null in append mode
    echo "USER $username does not exist"
    exit 1
fi

# check if you're trying to change root password or password of a user with uid <= 1000
if [ "$(id -u "$username")" -le 1000 ]; then
    echo "You cannot password of user with uid <= 1000"
    exit 1
fi

# change password
echo "$username":"$password" | sudo chpasswd
# sudo usermod --password "$(openssl passwd -1 "$password")" "$username"

echo "password successfully changed for $username"
exit 0
