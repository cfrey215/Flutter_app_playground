#!/bin/sh -l

echo
echo "PATH IS =====> $PATH"
echo
# cd root/.pub-cache/bin || exit
# ls


echo "Some Var outputs:"
echo "GITHUB_WORKSPACE var ===> $GITHUB_WORKSPACE"
echo "HOME var ===> $HOME"

echo
echo
echo "==> Root Directory Listing…"
ls
echo

echo "==> GITHUB_WORKSPACE/workspace Directory Listing…"
cd "$GITHUB_WORKSPACE"/workspace || exit
ls
echo

echo "==> HOME/workspace Directory Listing…"
cd "$HOME" || exit
ls
echo

# echo "==> /home/runner/work/_temp/_github_home Directory Listing…"
# cd "/home/runner/work/_temp/_github_home" || exit
# ls
# echo

# Retrieve the list of users using getent command and store it in a variable
# echo "==> USER Listing…"
# user_list=$(getent passwd | cut -d: -f1)
# # Print the list of users\
# echo "$user_list"

echo
echo

# patrol --version
flutter --version
flutter doctor

echo "Hello $1"
time=$(date)
# echo "time=$time" >> "$GITHUB_OUTPUT"

echo "##[set-output name=time]$time"