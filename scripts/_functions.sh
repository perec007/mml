#!/bin/bash

#init config
. $(ls /etc/mml/mml.cfg ~/mml/mml.cfg /opt/mml.cfg ../mml.cfg 2> /dev/null  | cut -f 1)


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

