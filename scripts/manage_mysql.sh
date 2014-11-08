#!/bin/bash

#init config
. $(ls /etc/mml/mml.cfg ~/mml/mml.cfg /opt/mml.cfg ../mml.cfg 2> /dev/null  | cut -f 1)
. $mml_work/scripts/_functions.sh



action=$1

case $action in
createdb)
	database=$2
	check_input $# 2
-----
;;

dropdb)
	database=$2
	check_input $# 2
--------

;;

reload)
service mysql nginx
;;

dialog)
cat <<EOF
createdb|Добавление домена|Добавление http домена, создание php-fpm пользователя, и типового конфига для nginx и отдельного пула php-fpm| --inputbox Domainname: 15 51 |x1 
dropdb|Удаление домена|Удаление http домена. Удаляются конфиги виртуального хоста, php-fpm user и конфиг, и вся структура каталога.| --inputbox Domainname: 15 51 |x1
reload|Рестарт nginx + php-fpm| service nginx reload && service php-fpm reload
EOF
;;

*|help )
cat <<END
$0 {adddom|deldom|showdom} "httpdomain" 
Этой командой производится добавление или удаление домена. 
Создание домена происходит вместе с созданием всей структуры папок, и раздачей необходимых прав nginx и fpm серверу.
Удаление ведет к удалению структуры каталогов, конфигов.

$0 {useradd|userdel}   "user" "shell" "pass"
Добавление и удаление пользователя в системе. 
При добавлении пользователя система генерирует 3 случайных пароля и предлагается выбрать один из них.
При удалении не удаляется домашний каталог пользователя! 

$0 {userdelperm|useraddperm}   "httpdomain" "user"
Данная команда раздает и убирает добавленному предыдущей командой пользователю необходимые права для доступа к соостветствующему домену, посредством системы файловой acl.


!!!Внимание!!!
Ни одна из этих команд самостоятельно не рестартует сервисы. Чтобы перезапустить дополнительно использовать команду reload либо сделать это руками:
service nginx reload && service php-fpm reload

END
;;

esac



