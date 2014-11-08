#!/bin/bash


#init config
. $(ls /etc/mml/mml.cfg ~/mml/mml.cfg /opt/mml.cfg ../mml.cfg 2> /dev/null  | cut -f 1)
. $mml_work/scripts/_functions.sh


action=$1


case $action in
initweb)
        puppet apply --verbose puppet/init_webdirnginx.pp
       ;;

initmysql)
		puppet apply puppet/init_mysql.pp
        
;;

initpostgresql)
        puppet apply puppet/init_postgresql.pp
;;

dialog)
cat << EOF 
initweb|Cоздание структуры веб каталогов nginx+php-fpm| Эта команда производит инициализацию структуты катлогов, и также устанавливает обязательный фронтэнд nginx. Кроме того заменяется стандартный конфиг, создается домен по умолчанию.
initmysql|Установка и первоначальная настройка mysql-server | Данная команда позволяет установить сервер баз данных mysql. Устанавливается последняя версия. Также генерируется случайный пароль и записывается в файл /root/.my.cnf, после чего для вход в mysql пользователю root достаточно просто набрать команду mysql.
EOF

esac

