#!/bin/bash

. mml.cfg

export DIALOG=${DIALOG=dialog}
export tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
export all_userscript=$(find $mml_work/scripts/ -type f -perm 755)

#trap "cat $tempfile; rm -f $tempfile" 0 1 2 5 15


echo  $all_userscript | tr ' ' \\n | \
	awk  'BEGIN { print "$DIALOG --clear --title \"CASE\" --menu \"Выберите скрипт:\" 30 61 10  " } { print  "\""NR"\" \"" $1"\"  " } END { print "2> $tempfile" } ' | \
	tr \\n ' '  | bash

id_script=$(echo $all_userscript | cut -d ' ' -f $(cat $(echo $tempfile))) 
$id_script dialog | \
	awk -F '|' 'BEGIN { print "dialog --clear --title \"CASE\" --menu \"Выберите параметр:\" 30 61 10  " } { print  "\""$1"\" \"" $2"\"  " } END { print "2> $tempfile" } ' | \
	tr \\n ' '  | bash

	
id_param=$(cat $tempfile)

echo $id_script $id_param



