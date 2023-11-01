#!/bin/bash
# no need to run as root
# checkifuserexist.sh <username>
# check if user exists

set -eo pipefail # see - http://redsymbol.net/articles/unofficial-bash-strict-mode/

if [ -z "$1" ]; then
    echo "No username supplied"
    exit 1
fi

username=$1

#check if user already exists
if ! id "$username" >>/dev/null 2>&1; then # redirect stderr to /dev/null in append mode
    echo "USER $username does not exist"
    exit 1
elif id "$username" >>/dev/null 2>&1; then
    echo "$username exists"
    exit 0
fi
