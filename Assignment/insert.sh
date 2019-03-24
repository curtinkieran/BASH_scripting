#!/bin/bash

#check parameters supplied to the script
if [ "$#" -ne 3 ]; then
	echo "You do not have the correct number of parameters.  This script takes exactly 3 parameters."
	exit 1
elif [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
	echo "Error: Parameters can not be an empty string"
	exit 1
fi

#lock the database
./P.sh $0 $1

#check if database and table are valid
if [ ! -e "$1" ]; then
	echo "The database does not exist"
	./V.sh $0 $1
	exit 1
elif [ ! -e "./$1/$2" ]; then
        echo "The table does not exist"
	./V.sh $0 $1
	exit 1
fi 

#declare 2 variables, number of columns in the request, and number of columns in the table
x=$(echo $3 | sed "s/,/\n/g" | wc -l) 2> /dev/null
y=$(head -n 1 ./$1/$2 | sed "s/,/\n/g" | wc -l) 2> /dev/null

#check if they are compatable
if [ $x -ne $y ]; then
	echo "Error: number of columns in tuple does not match schema"
	./V.sh $0 $1
	exit 1
else
	#append new columns into the table
	echo "$3" >> ./$1/$2
	echo "OK: tuple inserted"
	./V.sh $0 $1
	exit 0
fi	
