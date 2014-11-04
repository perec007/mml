#!/bin/bash

. mml.cfg

export DIALOG=${DIALOG=dialog}
export tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
export all_userscript=$(find $mml_work/scripts/ -type f -perm 755)

#trap "cat $tempfile; rm -f $tempfile" 0 1 2 5 15

#Выбор модуля
echo  $all_userscript | tr ' ' \\n | \
	awk  'BEGIN { print "$DIALOG --clear --title \"CASE\" --menu \"Выберите скрипт:\" 30 61 10  " } { print  "\""NR"\" \"" $1"\"  " } END { print "2> $tempfile" } ' | \
	tr \\n ' '  | bash

#Выбор действия в модуле
id_script=$(echo $all_userscript | cut -d ' ' -f $(cat $(echo $tempfile))) 
$id_script dialog | \
	awk -F '|' 'BEGIN { print "$DIALOG --clear --title \"CASE\" --menu \"Выберите параметр:\" 30 61 10  " } { print  "\""$1"\" \"" $2"\"  " } END { print "2> $tempfile" } ' | \
	tr \\n ' '  | bash


	
#Выбор дополнительных параметров для действия
pre_param=$(cat $tempfile)
add_dialog_param=$($id_script dialog | grep $pre_param | cut -d '|' -f 4 |wc -w)
if [ $add_dialog_param -ne 0 ] 
then
	$id_script dialog | grep $pre_param | \
	awk -F '|' 'BEGIN { print "$DIALOG --clear --title \"Дополнительные параметры запуска команды:\" " } { print $4 } END { print " 2> $tempfile " } ' | \
	tr \\n ' '  | bash
	
	x1=$(cat $tempfile | awk '{ print $1 }' )
	x2=$(cat $tempfile | awk '{ print $2 }' )
	x3=$(cat $tempfile | awk '{ print $3 }' )
	x4=$(cat $tempfile | awk '{ print $4 }' )
	x5=$(cat $tempfile | awk '{ print $5 }' )
	
	post_param=$($id_script dialog |grep $pre_param | awk  -F '|' '{ print $5 }' | sed "s/x1/$x1/g; s/x2/$x2/g; s/x3/$x3/g; s/x4/$x4/g; s/x5/$x5/g")
	
fi


command=$(echo $id_script $pre_param $post_param)
echo $DIALOG --clear --title \"Подтвердите запуск команды:\" --yesno \"$command\" 30 61  " 2> $tempfile "  | \
	tr \\n ' '  | bash

if [ $? -eq 0 ]
then
	$command
else 
	exit 1
fi

