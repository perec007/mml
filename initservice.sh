#!/bin/bash

action=$1



case $action in

initweb)
        if [ $(dpkg --status puppet  2>&1 |grep "Status: install ok installed" | wc -l) -eq "1" ];then
        puppet apply puppet/init_webdirnginx.pp
        else
        echo "В системе не установлен puppet, сейчас будет произведена установка."
        apt-get update && apt-get install puppet && ./$0 initweb
        fi
;;



*)
cat <<END
$0 {initweb}
Эта команда производит инициализацию структуты катлогов, и также устанавливает обязательный фронтэнд nginx.
Кроме того заменяется стандартный конфиг, создается домен по умолчанию.
Чтобы попроавить и привести права структуры каталогов в безопасное состояние необходимо заново выполнить эту команду. Puppet все сделает сам.
END
;;
esac

