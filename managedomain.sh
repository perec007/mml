#!/bin/bash

action=$1

          

case $action in
showdom)
echo enabled domains:
ls -l /etc/nginx/sites-enabled/
;;

adddom)
domain=$2

		test -f /etc/nginx/sites-enabled/$domain".conf" && echo Domain $domain is exists!!! EXIT! && exit	

				useradd -s /sbin/nologin -d /dev/null  fpm.$domain
                
				mkdir /storage/www/$domain
                mkdir /storage/www/$domain/www
                mkdir /storage/www/$domain/log
                mkdir /storage/www/$domain/tmp

				setfacl -m u:fpm.$domain:rx /storage/ /storage/www/ /storage/www/$domain
                setfacl -m u:fpm.$domain:rwx,d:fpm.$domain:rwx /storage/www/$domain/tmp /storage/www/$domain/www /storage/www/$domain/log
                setfacl -m u:fpm.$domain:rwx,d:fpm.$domain:rwx /storage/socket/
				
				setfacl -m u:NGINX:rwx,d:NGINX:rwx /storage/www/$domain/log/
				setfacl -m u:NGINX:rx,d:NGINX:rx /storage/www/$domain/www/
		
				
                cd /etc/nginx/sites-available/
                cp template $domain.conf
				ln -s /etc/nginx/sites-available/$domain.conf /etc/nginx/sites-enabled/$domain.conf 
                sed -i  "s/DOMAIN/$domain/g" $domain.conf
                sed -i  "s/FPMUSER/fpm.$domain/g" $domain.conf

                cd /etc/php5/fpm/pool.d/
                cp TEMPLATE $domain.conf
                sed -i  "s/DOMAIN/$domain/g" $domain.conf
                sed -i  "s/FPMUSER/fpm.$domain/g" $domain.conf
				echo "CREATE $domain <br> $(date)" >> /storage/www/$domain/www/index.php


				echo "Create:
				Domain:		$domain
				FPMUser:	fpm.$domain
				Path to domain www: /storage/www/$domain/www
				"
		
        ;;







deldom)
domain=$2
        rm -r /storage/www/$domain
        rm /etc/nginx/sites-available/$domain.conf
        rm /etc/php5/fpm/pool.d/$domain.conf
		rm /etc/nginx/sites-enabled/$domain.conf

		userdel -f fpm.$domain 

		echo done

;;

useradd)
user=$2
	grep $user: /etc/passwd > /dev/null  && echo User $user is exisis! EXIT!!! && exit 

		useradd -s /bin/bash -m $user
        echo "Use password to new username: passwd $user"
        apg -n 3
        passwd $user
;;

useraddperm)
		domain=$2
		user=$3
		
		setfacl -m u:$user:x  /storage/ /storage/www/
        setfacl -R -m u:$user:x   /storage/www/$domain/
        setfacl -R -m d:$user:rwx,u:$user:rwx   /storage/www/$domain/tmp /storage/www/$domain/www
        setfacl -R -m d:$user:rx,u:$user:rx   /storage/www/$domain/log	

	mkdir -p /home/$user/domains/$domain/
	ln -s  /storage/www/$domain/tmp /home/$user/domains/$domain/ 
	ln -s  /storage/www/$domain/www /home/$user/domains/$domain/ 
	ln -s  /storage/www/$domain/log /home/$user/domains/$domain/ 
		
;;
 
userdelperm)
		domain=$2
		user=$3
		setfacl -x u:$user /storage/ /storage/www/
        setfacl -R -x u:$user   /storage/www/$domain/
        setfacl -R -x d:$user   /storage/www/$domain/
	rm /home/$user/domains/$domain/www  
	rm /home/$user/domains/$domain/log    
	rm /home/$user/domains/$domain/tmp    
 
;;

userdel)
user=$2
	userdel -f $user
	rm -rf /home/$user/
;;

*)
cat <<END
$0 {adddom|deldom|showdom} "httpdomain" 
Этой командой производится добавление или удаление домена. 
Создание домена происходит вместе с созданием всей структуры папок, и раздачей необходимых прав nginx и fpm серверу.
Удаление ведет к удалению структуры каталогов, конфигов.

$0 {useradd|userdel}   "user"
Добавление и удаление пользователя в системе. 
При добавлении пользователя система генерирует 3 случайных пароля и предлагается выбрать один из них.
При удалении не удаляется домашний каталог пользователя! 

$0 {userdelperm|useraddperm}   "httpdomain" "user"
Данная команда раздает и убирает добавленному предыдущей командой пользователю необходимые права для доступа к соостветствующему домену, посредством системы файловой acl.


!!!Внимание!!!
Ни одна из этих команд самостоятельно не рестартует сервисы. Чтобы перезапустить nginx и php-fpm необходимо использовать команду:
service nginx reload && service php-fpm reload

END
;;
esac



