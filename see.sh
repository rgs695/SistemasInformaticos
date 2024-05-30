#!/bin/bash
#taking a filename name as argument which uses ‘ls’ if
#the file is a directory and ‘more’ if not.

if [ -d $1 ]; then
    ls $1
    echo "This is a directory"
else
    more $1
    echo "This is not a directory"
fi