#!/bin/bash

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



if [ -f /etc/debian_version ]
then 
	check_debian
elif [ -f /etc/centos-release ]
then 
	check_centos
else 
	echo "OS не поддерживается!"
fi

