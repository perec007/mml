#!/bin/bash

#init config
. $(ls /etc/mml/mml.cfg ~/mml/mml.cfg /opt/mml.cfg ../mml.cfg 2> /dev/null  | cut -f 1)
. $mml_work/scripts/_functions.sh


check_debian() {
	soft="acl dialog puppet"
	for check in `echo $soft`
	do
		if [ "$( dpkg -l | grep ^ii\ \ $check\  | wc -l )" != "1" ]
		then
			echo "Не найдена утилита: $check"
			help=1
		fi
	done

	if [ "$help" == "1" ]
	then 
		echo Для пакетной установки всего необходимого софта используйте команду:
		echo apt-get install $soft
		exit 1
	fi
}

standart_test() {
if [ "$mml_opt" = ""  ] |  [ "$mml_opt" = "/" ] 
then
	echo "Config error. Dir \"opt\" wrong!"
fi

if [ "$(whoami)" != "root" ]
then 
	echo Need root privileges.
	exit 1
elif [ -f /etc/debian_version ]
then 
	check_debian
elif [ -f /etc/centos-release ]
then 
	check_centos
	# в разработке
else 
	echo "OS не поддерживается!"
fi


}

standart_test



