mml
===

План работ
1. Написание скрипта позволяющего создавать структуру каталогов веб сервера nginx + php-fpm
2. Написание скрипта позволяющего создавать структуру каталогов сервера nginx + apache 2.2
3. Написание документации к работе скрипта и структуре которая создается.
4. Разработка скрипта для установки mysql или mysql percona на выбор.
5. Разработка скрипта для установки posgreesql.
4. Создание интерфейса для управления mysql серверов.
5. 


Планы на будущее:
1. первоначальная настройка репликации mysql 
2. Полуавтоматическое (по команде админа) восстановление репликации после сбоя
3. 



Cтурктура каталогов nginx+php-fpm:
Схема с php-fpm является наиболее безопасной, каждый домен запускается от отдельного пользователя, и изолирован на уровне acl файловой системы от других доменов. При необходимости ftp и sftp пользователей можно запереть в chroot окружение, не давая шелла. Права всегда на все домены на даются минимальные.

/storage/
├── socket 				- здесь располагаются сокеты php-fpm
└── www	
	└── domain.ru		- корневая папка конкретного домена domain.ru
        ├── log			- логи домена domain.ru
        ├── tmp			- временные файлы domain.ru
        └── www			- корневая директория domain.ru

Права на каталоги:
/storage/						= root:root 2750, u:nginx:x, u:fpmdomainru:x
/storage/socket/				= root:root 2750 u:nginx:rwx, u:fpmdomainru:rwx
/storage/www/					= root:root 2750, u:nginx:x, u:fpmdomainru:x
/storage/www/domain.ru/			= root:root 2750, u:nginx:x, u:fpmdomainru:x, u:user:rx
/storage/www/domain.ru/www/		= root:root 2750, u:nginx:rx, u:fpmdomainru:rwx, u:user:rwx
/storage/www/domain.ru/log/		= root:root 2750, u:nginx:rwx, u:fpmdomainru:rwx, u:user:rx
/storage/www/domain.ru/tmp/		= root:root 2750, u:nginx:rwx, u:fpmdomainru:rwx, u:user:rwx

