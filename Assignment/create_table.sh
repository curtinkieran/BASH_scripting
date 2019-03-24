#!/bin/bash

#check parameters supplied to the script to make sure they are valid
if [ "$#" -ne 3 ]; then
	echo "You do not have the correct number of parameters.  This script takes exactly 3 parameters."
	exit 1
elif [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
	echo "Error: Parameters can not be an empty string"
	exit 1
fi

#lock the database
./P.sh $0 $1

#check if database and table exist
if [ ! -e "$1" ]; then
	echo "The database does not exist"
	./V.sh $0 $1
	exit 1

elif [ -e "./$1/$2" ]; then
	echo "The table already exists"
	./V.sh $0 $1
	exit 1
else
	#make a file located in $1 with the name $2
	touch ./$1/$2
	#append $3 into this new file
	echo "$3" >> ./$1/$2
	echo "OK: Table created"
	./V.sh $0 $1
	exit 0
fi
