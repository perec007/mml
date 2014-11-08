﻿mml
===
managment linux
---



Набор скриптов и псевдографических интерфейсов для упращения стандартных и рутинных задач в администрировании. Набор скриптов не способен заменить администратора, и требует минимальных знаний консоли. 
Задачи которые можно переложить на mml скрипты:
- инсталляция веб окружения php-fpm
- обязательная установка nginx фронтэнда. 
- создание-удаление веб доменов.
- создание-удаление пользователей, раздача прав
- инсталляция серверов баз данных, mysql.


===

План работ:
- Написание скрипта позволяющего создавать структуру каталогов веб сервера nginx + php-fpm
- Написание скрипта позволяющего создавать структуру каталогов сервера nginx + apache 2.2
- Написание документации к работе скрипта и структуре которая создается.
- Разработка скрипта для установки mysql или mysql percona на выбор.
- Разработка скрипта для установки posgreesql.
- Создание интерфейса для управления mysql и postgreaql серверами.
- Установка pgadmin и myadmin.
- создание ftp и sftp учеток, в chroot окружении домена.



Планы на будущее:
- первоначальная настройка репликации mysql 
- Полуавтоматическое (по команде админа) восстановление репликации после сбоя
 


mml.sh : Главный интерфейс к набору скриптов. Для взаимодействия со скриптами написан интуитивно понятный интерфейс - обвязка. 
Интерфейс взаимодействия: 
- каждый скрипт должен отвечать ему по запросу mml таблицей следующего формата:
- action|help|long_help|dialog_param|start_param
- action - действие
- help - короткая справка
- long_help - расширенная длинная справка по действию команды
- dialog_param - параметры, которые нобходимо дополнительно запросить в диалоге у пользователя (в формате dialog)
- start_param - каким именно образом преобразовывать параметры и в каком порядке их подставлять. Максимум 5 параметров, значения идут в порядке заданном в предыдущим пунктом, обозначаются x1, x2 ... x5


Cтурктура каталогов nginx+php-fpm:
Схема с php-fpm является наиболее безопасной, каждый домен запускается от отдельного пользователя, и изолирован на уровне acl файловой системы от других доменов. При необходимости ftp и sftp пользователей можно запереть в chroot окружение, не давая шелла. Права всегда на все домены на даются минимальные.

Внутренние глобальные переменные: 

$opt=/__MML_OPT__/


- /__MML_OPT__/
- ├── socket 				- здесь располагаются сокеты php-fpm
- └── www	
-	└── domain.ru		- корневая папка конкретного домена domain.ru
-		├── log			- логи домена domain.ru
-       ├── tmp			- временные файлы domain.ru
-        └── www			- корневая директория domain.ru

Права на каталоги:
- /__MML_OPT__/						= root:root 2750, u:nginx:x, u:fpmdomainru:x
- /__MML_OPT__/socket/				= root:root 2750 u:nginx:rwx, u:fpmdomainru:rwx
- /__MML_OPT__/www/					= root:root 2750, u:nginx:x, u:fpmdomainru:x
- /__MML_OPT__/www/domain.ru/			= root:root 2750, u:nginx:x, u:fpmdomainru:x, u:user:rx
- /__MML_OPT__/www/domain.ru/www/		= root:root 2750, u:nginx:rx, u:fpmdomainru:rwx, u:user:rwx
- /__MML_OPT__/www/domain.ru/log/		= root:root 2750, u:nginx:rwx, u:fpmdomainru:rwx, u:user:rx
- /__MML_OPT__/www/domain.ru/tmp/		= root:root 2750, u:nginx:rwx, u:fpmdomainru:rwx, u:user:rwx



Скрипты:
./initservice.sh {initweb}
- Эта команда производит инициализацию структуты катлогов, и также устанавливает обязательный фронтэнд nginx.
Кроме того заменяется стандартный конфиг, создается домен по умолчанию.
Чтобы попроавить и привести права структуры каталогов в безопасное состояние необходимо заново выполнить эту команду. Puppet все сделает сам.

./initservice.sh {initmysql}
- Данная команда позволяет установить сервер баз данных mysql. Устанавливается последняя версия.
Также генерируется случайный пароль и записывается в файл /root/.my.cnf, после чего для вход в mysql пользователю root достаточно просто набрать команду mysql.

./managedomain.sh {adddom|deldom|showdom} "httpdomain"
- Этой командой производится добавление или удаление домена.
Создание домена происходит вместе с созданием всей структуры папок, и раздачей необходимых прав nginx и fpm серверу.
Удаление ведет к удалению структуры каталогов, конфигов.

./managedomain.sh {useradd|userdel}   "user"
- Добавление и удаление пользователя в системе.
При добавлении пользователя система генерирует 3 случайных пароля и предлагается выбрать один из них.
При удалении не удаляется домашний каталог пользователя!

./managedomain.sh {userdelperm|useraddperm}   "httpdomain" "user"
- Данная команда раздает и убирает добавленному предыдущей командой пользователю необходимые права для доступа к соостветствующему домену, посредством системы файловой acl.


!!!Внимание!!!
--------------
Ни одна из этих команд самостоятельно не рестартует сервисы. Чтобы перезапустить nginx и php-fpm необходимо использовать команду:
service nginx reload && service php-fpm reload
