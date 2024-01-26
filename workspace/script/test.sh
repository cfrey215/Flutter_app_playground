#!/bin/bash -l

arg1=${1}
arg2=${2}
arg3=${3}
# Run the script in an infinite loop
echo "Argument 1: $arg1"
echo "Argument 2: $arg2"
echo "Argument 3: $arg3"

echo "RETURN_BS_ID=abcdefg123456789" >> "$GITHUB_OUTPUT"