#!/bin/bash

#create server pipe
mkfifo server.pipe

#elegant way to exit the script
trap ctrl_c INT
function ctrl_c() {
	rm server.pipe
	exit 0
}

#read request from the server pipe in form of an array
while true; do
read -a ARRAY < server.pipe

#use template proided in PDF for pattern matching
case "${ARRAY[0]}" in 
	"create_database")
	#save client pipe as a variable for easier use
	return=${ARRAY[1]}.pipe
	#pass arguments to the script and execute, sending result to the client pipe.  Do all this in the background.
	./${ARRAY[0]}.sh ${ARRAY[2]} > "$return" &;;

	"create_table")
	return=${ARRAY[1]}.pipe
	./${ARRAY[0]}.sh ${ARRAY[2]} ${ARRAY[3]} ${ARRAY[4]} > "$return" &;;

	"insert")
	return=${ARRAY[1]}.pipe
	./${ARRAY[0]}.sh ${ARRAY[2]} ${ARRAY[3]} ${ARRAY[4]} > "$return" &;;

	"select")
	return=${ARRAY[1]}.pipe
	./${ARRAY[0]}.sh ${ARRAY[2]} ${ARRAY[3]} ${ARRAY[4]} ${ARRAY[5]} ${ARRAY[6]} > "$return" &;;
	"shutdown")
	return=${ARRAY[1]}.pipe
	echo "Server is shutting down." > "$return"  
	#terminate the script and remove pipe.
	ctrl_c;;
	
	*)
	echo "Error: bad request" > "$return"
esac
done
