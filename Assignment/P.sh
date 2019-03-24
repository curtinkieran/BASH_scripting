#!/bin/bash

#try to create a hard link using the script as the link, and the database as the "name-lock".  If it cannot be created, sleep 1 and try again.

while ! ln "$1" "$2-lock"; do
sleep 1
done
exit 0
