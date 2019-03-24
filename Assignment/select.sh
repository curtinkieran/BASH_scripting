#/bin/bash

#check parameters supplied to the script
if [ $# -lt 2 ] || [ $# -gt 5 ]; then
        echo "You do not have the correct number of parameters.  This script takes 2, 3 or 5 parameters."
        exit 1
elif [ -z $1 ] || [ -z $2 ]; then
        echo "You can not have an empty string as an argument for the first or second parameter"
        exit 1
fi

#lock the database
./P.sh $0 $1

if [ ! -e "$1" ]; then
        echo "The database does not exist"
	./V.sh $0 $1
        exit 1
elif [ ! -e "./$1/$2" ]; then
        echo "The table does not exist"
        ./V.sh $0 $1
	exit 1

#if no argument is supplied, then print everything in the file
elif [ $# -eq 2 ]; then
	echo "start_results"
	tail -n +2 ./$1/$2
	echo "end_results"
	./V.sh $0 $1
	exit 0
fi

#declare variables to be used for checking number of columns in client request and in table, and also the number of lines in the table to be printed.  More info in PDF report.
x=$(echo $3 | sed "s/,/\n/g" | wc -l) 2> /dev/null
y=$(head -n 1 ./$1/$2 | sed "s/,/\n/g" | wc -l) 2> /dev/null
z=$(tail -n +2 ./$1/$2 | wc -l) 2> /dev/null
fdem=$3
range1=$(($z+1))

#go through all columns and save their value to a variable and export it for use later
for i in $(seq 1 $x);
do
        export column$i=$(echo "$3" | cut -d"," -f$i) 2> /dev/null
done

#check that all of the ccolumns requested by the client are valid
for i in $(seq 1 $x);
        do
                newvar=column$i
                if [ ${!newvar} -lt 1 ] || [ ${!newvar} -gt $y ]; then
                        echo "Error: The number of columns in this table is $y"
                        exit 1
                fi
        done

#check to make sure they are optomising their search query
if [ $x -gt $y ]; then
        echo "Hmmmm.  You are searching for more columns than necessary!  Please optimize your search and remove duplicate column requests."
	./V.sh $0 $1
        exit 1

#print results that match the query by going through each line of the file individually
elif [ $# -eq 3 ]; then
	echo "start_results"
	for i in $(seq 2 $range1);
	do
		result=""
		result=(`sed -n "$i"p ./$1/$2 | cut -d"," -f$fdem`)
		echo $result
	done
	echo "end_results"
	./V.sh $0 $1
	exit 0

#allow user to add a WHERE clause to their query.
elif [ $# -eq 5 ]; then
	echo "start_results"
	for i in $(seq 2 $range1);
	do
		a=$(sed -n "$i"p ./$1/$2 | cut -d"," -f$4)
		if [ "$5" = "$a" ]; then
			result=""
			result=$(sed -n "$i"p ./$1/$2 | cut -d"," -f$fdem)
			echo $result
		fi
	done
	echo "end_results"
	./V.sh $0 $1	
	exit 0
fi
