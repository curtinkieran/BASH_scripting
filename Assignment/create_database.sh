#!/bin/bash

#check the parameters supplied to the script
if [ $# -ne 1 ]; then
	echo "Error: Wrong number of parameters given.  This script requires 1 parameter." 
	exit 1
elif [ -z $1 ]; then
	echo "Error: Parameter can not be empty string" 
	exit 1
fi

#lock the database (even though it may not exist, we still have the name as $1
./P.sh $0 $1

#check if database exists
if [ -e "$1" ]; then
	echo "Error: Database already exits" 
	./V.sh $0 $1
	exit 1
else
	#make directory
	mkdir $1
	echo "OK: Database created"
	#unlock database	
	./V.sh $0 $1
	exit 0
fi 
