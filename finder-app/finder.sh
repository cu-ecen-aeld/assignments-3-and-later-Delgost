#!/bin/sh
#
# Script find.sh for Assignment 1.
# Features:
#    1. Count number of files in user-defined directory
#    2. Count number of matching lines within user-defined directory files based on user-defined search string.
# Usage: 
#   find.sh <path-to-directory> <search-string>

# User arguments
readonly filesdir=$1
readonly searchstr=$2

# Check number of arguemnts
if [ "$#" -ne 2 ]; then
    echo "Not correct number of arguments supplied. Expected number of arguments: 2"
    echo "Usage: $0 <path-to-directory> <search-string>"
    exit 1
fi

# Verify directory argument and perform action
if [ -d $1 ]; then 
    number_of_files=$(( $(find $filesdir | wc -l) - 1 )) # -1 : Current directory reference doesn't count
    number_of_matching_lines=$(grep -R $searchstr $filesdir | wc -l) 
    echo "The number of files are $number_of_files and the number of matching lines are $number_of_matching_lines."
else
    echo "Argument $filesdir is not a valid directory"
    exit 1
fi
