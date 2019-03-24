#!/bin/bash

#create more elegant way to exit script
trap ctrl_c INT
function ctrl_c() {
        rm $pipe
	exit 0
}

#check that a client ID has been supplied
if ! [ $# -eq 1 ]; then
	echo "This script takes exactly 1 parameter"
	exit 1
else
	#make pipe and save as variable for easier use
	mkfifo $1.pipe
	pipe=$1.pipe
	while true; do

#read from standard input and save to an array
read -a CLIENTARRAY input
case "${CLIENTARRAY[0]}" in
	"create_database")
	if [ ${#CLIENTARRAY[@]} -eq 2 ]; then
	#send the request to the server pipe by indexing the array
	echo ${CLIENTARRAY[0]} $1 ${CLIENTARRAY[1]} > server.pipe
	#allow time for action to occur
	sleep 1	
	#save response from server to a variable
	read answer < "$pipe"
	#print response
	echo $answer
	else 
		 echo "Error: bad request" 
	fi;;

	"create_table")
	if [ ${#CLIENTARRAY[@]} -eq 4 ]; then
	#always send client name ($1) with every request to the server
	echo ${CLIENTARRAY[0]} $1 ${CLIENTARRAY[1]} ${CLIENTARRAY[2]} ${CLIENTARRAY[3]} > server.pipe
	sleep 1
	read answer < "$pipe"
	echo $answer
	else
                 echo "Error: bad request"
	fi;;

	"insert")
	if [ ${#CLIENTARRAY[@]} -eq 4 ]; then
	echo ${CLIENTARRAY[0]} $1 ${CLIENTARRAY[1]} ${CLIENTARRAY[2]} ${CLIENTARRAY[3]} > server.pipe
	sleep 1
        read answer < "$pipe"
        echo $answer
	else
                 echo "Error: bad request" 
	fi;;

	"select")
	#check to see if query is a normal SELECT or WHERE SELECT
	if [ ${#CLIENTARRAY[@]} -eq 4 ] || [ ${#CLIENTARRAY[@]} -eq 3 ]; then
	echo ${CLIENTARRAY[0]} $1 ${CLIENTARRAY[1]} ${CLIENTARRAY[2]} ${CLIENTARRAY[3]} > server.pipe
	sleep 1
	#while there is a word in the pipe, echo the word.  Example taken from stack overflow on how to read a file line by line.
	while read word; do
  		echo "$word"
	done < $pipe
	elif [ ${#CLIENTARRAY[@]} -eq 6 ]; then
	echo ${CLIENTARRAY[0]} $1 ${CLIENTARRAY[1]} ${CLIENTARRAY[2]} ${CLIENTARRAY[3]} ${CLIENTARRAY[4]} ${CLIENTARRAY[5]} > server.pipe 
	sleep 1
	while read sword; do
		echo "$sword"
	done < $pipe
	else
                 echo "Error: bad request" 
	fi;;
	
	"shutdown")
	if [ ${#CLIENTARRAY[@]} -eq 1 ]; then
	echo ${CLIENTARRAY[0]} $1 > server.pipe
	sleep 1
	read answer < "$pipe"
	echo $answer
	fi;;

	"exit")
	if [ ${#CLIENTARRAY[@]} -eq 1 ]; then
	echo "Client shutting down."
	ctrl_c
	fi;;
 
	*)
	echo "Error: bad request"
esac
done
fi
