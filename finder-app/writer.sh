#!/bin/bash
#
# Script writer.sh for Assignment 1.
# Features:
#    1. Creates a new file
#    2. Count number of matching lines within user-defined directory files based on user-defined search string.
# Usage: 
#   writer.sh <path-to-filename> <text-string>

# User arguments
readonly writefile=$1
readonly writedir=$(dirname "$writefile")
readonly writestr=$2

# Check number of arguemnts
if [ "$#" -ne 2 ]; then
        echo "Not correct number of arguments supplied. Expected number of arguments: 2"
        echo "Usage: $0 <path-to-filename> <text-string>"
        exit 1
fi

# Check if directory exists
if [ ! -d "$writedir" ]; then
    mkdir -p "$writedir"
    
    #Recheck if directory was created
    if [ ! -d "$writedir" ]; then
        echo "Directory to filepath could not be created"
        exit 1
    else
        echo "Directory to filepath created"
    fi
else
    echo "Directory to filepath exists"
fi

# Check if file exists
if [ ! -e "$writefile" ]; then
    touch "$writefile"

    # Recheck if file was created
    if [ ! -e "$writefile" ]; then
        echo "File could not be created"
        exit 1   
    else
        echo "File created"
    fi
else
    echo "File exists"
fi

# Write/Overwrite file with string
echo "$writestr" > $writefile