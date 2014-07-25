#!/bin/bash

action=$1

 

case $action in

initweb)
        if [ $(dpkg --status puppet  2>&1 |grep "Status: install ok installed" | wc -l) -eq "1" ];then
        puppet apply puppet/init_webdirnginx.pp
        else
        echo "В системе не установлен puppet, сейчас будет произведена установка!"
        apt-get update && apt-get install puppet && ./$0 initweb
        fi
;;

initmysql)
		if [ $(dpkg --status puppet  2>&1 |grep "Status: install ok installed" | wc -l) -eq "1" ];then
        puppet apply puppet/init_mysql.pp
        else
        echo "В системе не установлен puppet, сейчас будет произведена установка!"
        apt-get update && apt-get install puppet && ./$0 initmysql
        fi
;;
initpostgresql)
		if [ $(dpkg --status puppet  2>&1 |grep "Status: install ok installed" | wc -l) -eq "1" ];then
        puppet apply puppet/init_postgresql.pp
        else
        echo "В системе не установлен puppet, сейчас будет произведена установка!"
        apt-get update && apt-get install puppet && ./$0 postgresql
        fi
;;
*)
cat << END 
$0 {initweb}
Эта команда производит инициализацию структуты катлогов, и также устанавливает обязательный фронтэнд nginx.
Кроме того заменяется стандартный конфиг, создается домен по умолчанию.
Чтобы попроавить и привести права структуры каталогов в безопасное состояние необходимо заново выполнить эту команду. Puppet все сделает сам.

$0 {initmysql}
Данная команда позволяет установить сервер баз данных mysql. Устанавливается последняя версия. 
Также генерируется случайный пароль и записывается в файл /root/.my.cnf, после чего для вход в mysql пользователю root достаточно просто набрать команду mysql.

END
;;
esac

