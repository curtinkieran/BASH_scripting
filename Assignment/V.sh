#!/bin/bash

#remove the lock that is on the database

rm "$2-lock" 2>/dev/null
exit 0

