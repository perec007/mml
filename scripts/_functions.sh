#!/bin/bash



debug(){
	echo $?
	#cat $tempfile
	exit 1
}


check_input () {
real=$1
need=$2

if [ $real -lt $need ];
then 
	echo Необходимо $need аргумента. Передано $real!
	exit 1
fi
}

