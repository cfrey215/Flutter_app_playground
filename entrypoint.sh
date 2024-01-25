#!/bin/sh -l

curl -X GET "https://reqres.in/api/users/2"

echo
echo "$PATH"
echo
echo "===> sdkmanager --list_installed..."
sdkmanager --list_installed

# echo
# cd ../../..
# cd workspace || exit

echo
echo "==> Directory Listing…"
ls
echo

# DOESN"T WORK
# echo
# echo "==> Root User Directory Listing…"
# cd root || exit
# ls

# Retrieve the list of users using getent command and store it in a variable
user_list=$(getent passwd | cut -d: -f1)
# Print the list of users
echo "List of users:"
echo "$user_list"

echo
echo

patrol --version
flutter --version

echo "Hello $1"
time=$(date)
# echo "time=$time" >> "$GITHUB_OUTPUT"

echo "##[set-output name=time]$time"