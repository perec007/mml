#!/bin/bash

# IMPORT CONFIG
. mml.cfg

# PREPARE
./scripts/testsystem.sh || exit 1
./templates/gentemplates.sh


stop(){
	echo $?
	cat $tempfile
	exit
}

export DIALOG=${DIALOG=dialog}
export tempfile=`mktemp 2>/dev/null` || tempfile=/tmp/test$$
export all_userscript=$(find $mml_work/scripts/ -type f -perm 755)

# trap "rm -f $tempfile" 0 1 2 5 15

#Выбор модуля
echo  $all_userscript | tr ' ' \\n | \
	awk  'BEGIN { print "$DIALOG --clear --title \"CASE\" --menu \"Выберите скрипт:\" 30 61 10  " } { print  "\""NR"\" \"" $1"\"  " } END { print "2> $tempfile" } ' | \
	tr \\n ' '  | bash

[ $? -eq 0 ] || exit 1

id_script=$(echo $all_userscript | cut -d ' ' -f $(cat $(echo $tempfile))) 

# Проверка верности параметров
if [ "$($id_script dialog | wc -l)" -eq "0" ]
then 
	echo "Модуль не поддерживает работу в этом режиме."
	echo  "Dialog script error: null dialog string"
	exit 1 
elif [ "$($id_script dialog | wc -l)" -ne "$($id_script dialog | cut -d '|' -f 2 | wc -l)" ] 
then
	echo "Модуль не поддерживает работу в этом режиме."
	echo  "Dialog script error: minimum 2 parametr on dialog menu!"; 
	exit 1 
fi



#Выбор действия в модуле
$id_script dialog | \
	awk -F '|' 'BEGIN { print "$DIALOG --clear --title \"CASE\" --menu \"Выберите требуемое действие:\" 30 61 10  " } { print  "\""$1"\" \"" $2"\"  " } END { print "2> $tempfile" } ' | \
	tr \\n ' '  | bash

[ $? -eq 0 ] || exit 1

	
#Выбор дополнительных параметров для действия
pre_param=$( cat $tempfile )

# Если количество слов в 4м поле больше 0 предлагаем заполнить дополнительные поля.
add_dialog_param=$( $id_script dialog | grep $pre_param | cut -d '|' -f 4 |wc -w )


if [ $add_dialog_param -ne 0 ]
then
	$id_script dialog | grep $pre_param\| | \
	awk -F '|' 'BEGIN { print "$DIALOG --clear --title \"Дополнительные параметры запуска команды:\" " } { print $4 } END { print " 2> $tempfile " }' | \
	tr \\n ' '  | bash
	sed -i "s/\t/|/g" $tempfile


	
	x1=$(cat $tempfile | awk -F '|' '{ print $1 }' )
	x2=$(cat $tempfile | awk -F '|' '{ print $2 }' )
	x3=$(cat $tempfile | awk -F '|' '{ print $3 }' )
	x4=$(cat $tempfile | awk -F '|' '{ print $4 }' )
	x5=$(cat $tempfile | awk -F '|' '{ print $5 }' )
	
	post_param=$( $id_script dialog |grep $pre_param\| | awk  -F '|' '{ print $5 }' | sed "s,x1,$x1,g; s,x2,$x2,g; s,x3,$x3,g; s,x4,$x4,g; s,x5,$x5,g" )

fi


command=$(echo $id_script $pre_param $post_param)

echo $command

echo $DIALOG --clear --title \"Подтвердите запуск команды:\" --yesno \"$command\" 30 61  " 2> $tempfile "  | \
	tr \\n ' '  | bash

if [ $? -eq 0 ]
then
	$command
else 
	exit 1
fi

