#!/bin/bash

#init config
. $(ls /etc/mml/mml.cfg ~/mml/mml.cfg /opt/mml.cfg ../mml.cfg 2> /dev/null  | cut -f 1)
. $mml_work/scripts/_functions.sh

if [ "$mml_opt" = ""  ] |  [ "$mml_opt" = "/" ] 
then
	echo "Config error. Dir \"opt\" wrong!"
fi

action=$1

case $action in
showdom)
	check_input $# 1
	echo enabled domains:
	ls  /etc/nginx/sites-enabled/ | sed "s/.conf//g"
;;

adddom)
	domain=$2
	check_input $# 2


	test -f /etc/nginx/sites-enabled/$domain".conf" && echo Domain $domain is exists!!! EXIT! && exit	

	useradd -s /sbin/nologin -d /dev/null  fpm.$domain
			
	mkdir $mml_opt/www/$domain
	mkdir $mml_opt/www/$domain/www
	mkdir $mml_opt/www/$domain/log
	mkdir $mml_opt/www/$domain/tmp

	setfacl -m u:fpm.$domain:rx $mml_opt/ $mml_opt/www/ $mml_opt/www/$domain
	setfacl -m u:fpm.$domain:rwx,d:fpm.$domain:rwx $mml_opt/www/$domain/tmp $mml_opt/www/$domain/www $mml_opt/www/$domain/log
	setfacl -m u:fpm.$domain:rwx,d:fpm.$domain:rwx $mml_opt/socket/
			
	setfacl -m u:NGINX:rwx,d:NGINX:rwx $mml_opt/www/$domain/log/
	setfacl -m u:NGINX:rx,d:NGINX:rx $mml_opt/www/$domain/www/
	
			
	cd /etc/nginx/sites-available/
	cp template $domain.conf
	ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/$domain.conf 
	sed -i  "s/__WWWDOM__/$domain/g" $domain.conf
	sed -i  "s/__FPMUSER__/fpm.$domain/g" $domain.conf

	cd /etc/php5/fpm/pool.d/
	cp TEMPLATE $domain.conf
	sed -i  "s/__WWWDOM__/$domain/g" $domain.conf
	sed -i  "s/__FPMUSER__/fpm.$domain/g" $domain.conf
	echo "CREATE $domain <br> $(date)" >> $mml_opt/www/$domain/www/index.php


	echo "Create:
	Domain:		$domain
	FPMUser:	fpm.$domain
	Path to domain www: $mml_opt/www/$domain/www
	"
		
;;







deldom)
	check_input $# 2
	domain=$2

	rm -r $mml_opt/www/$domain
	rm /etc/nginx/sites-available/$domain.conf
	rm /etc/php5/fpm/pool.d/$domain.conf
	rm /etc/nginx/sites-enabled/$domain.conf

	userdel -f fpm.$domain 

	echo done

;;

useradd)
	check_input $# 2 # Обязателен только логин пользователя
	user=$2
	shell=$3 		; [ "$shell" == "" ] && unset shell
	password=$4		; [ "$password" == "" ] && unset password
	
	shell=${shell=/bin/bash}
	password=${password=$(apg -n 1)}
	
	
	
	if [ "$(grep $user: /etc/passwd |wc -l)" -ne "0" ]
	then	
		echo Useradd $user error!!! 
		exit 1 
	fi
	
 	useradd  -m -s $shell -p $( echo $password | openssl passwd -1 -stdin ) $user
	
	echo "
	Host: $(hostname)
	User: $user
	Password: $password
	"
	
	exit 0
;;

useraddperm)
	check_input $# 3
	domain=$2
	user=$3
	
	setfacl -m u:$user:x  $mml_opt/ $mml_opt/www/
	setfacl -R -m u:$user:x   $mml_opt/www/$domain/
	setfacl -R -m d:$user:rwx,u:$user:rwx   $mml_opt/www/$domain/tmp $mml_opt/www/$domain/www
	setfacl -R -m d:$user:rx,u:$user:rx   $mml_opt/www/$domain/log	

	mkdir -p /home/$user/domains/$domain/
	ln -s  $mml_opt/www/$domain/tmp /home/$user/domains/$domain/ 
	ln -s  $mml_opt/www/$domain/www /home/$user/domains/$domain/ 
	ln -s  $mml_opt/www/$domain/log /home/$user/domains/$domain/ 
	
	echo "
	Пользователю $user предоставлены права на домен $domain  
	Для удобства создана ссылка в домашнем каталоге.
	"
;;
 
userdelperm)
	check_input $# 3
	domain=$2
	user=$3
	setfacl -x u:$user $mml_opt/ $mml_opt/www/
	setfacl -R -x u:$user   $mml_opt/www/$domain/
	setfacl -R -x d:$user   $mml_opt/www/$domain/
	rm -I -r /home/$user/domains/$domain/
	echo "
	Пользователь $user лишен привилегий на домен $domain
	Символические ссылки также удалены.
	"
;;

userdel)
	check_input $# 2
	user=$2
	userdel -f $user
	rm -rf /home/$user/
;;

reload)
service reload nginx
service reload php-fpm 
;;
dialog)
cat <<EOF
adddom|Добавление домена|Добавление http домена, создание php-fpm пользователя, и типового конфига для nginx и отдельного пула php-fpm| --inputbox Domainname: 15 51 |x1 
deldom|Удаление домена|Удаление http домена. Удаляются конфиги виртуального хоста, php-fpm user и конфиг, и вся структура каталога.| --inputbox Domainname: 15 51 |x1
showdom|список доменных имен на сервере|Отобразить список доменных имен на сервере
useradd|Добавление пользователя|Добавление пользователя в систему| --inputbox Username: 15 51  --inputbox Shell: 15 51  --passwordbox Password: 15 51 | x1 x2 x3
userdel|Удаление пользователя|Удаление пользователя со всеми файлами|--inputbox Username: 15 51 |x1
useraddperm|Права на домен|Дать пользователю возможность редактировать файлы и просматривать логи определенного домена. В его каталоге для удобства создается симлинк на рабочий каталог| --inputbox Domainname: 15 51 --inputbox Username: 15 51 |x1 x2
userdelperm|Забрать права на домен|Забрать права редактирования и просмотра логов домена|--inputbox Domainname: 15 51 --inputbox Username: 15 51 |x1 x2
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



