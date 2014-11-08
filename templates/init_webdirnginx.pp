define  acl::setacl ($perm='---',$type='user',$user,$setdefault='false',$dir='',$recursion='false') {



        if ( $dir == '' ) {
                $path = $title
        } else {
                $path = $dir
        }

        if ( $recursion == true ) {
                $param = ' -R '
        }

        exec { "User $param $title":
                command                 =>  "/bin/setfacl $param -m $type:$user:$perm $path",
                logoutput               => true,
                unless                  => "/bin/getfacl $path 2>&1 | /bin/grep ^$type:$user:$perm",
                require => Package['acl'],
        }

        if ($setdefault == true) {
        exec { "Default $title":
                command                 =>  "/bin/setfacl $param  -m default:$type:$user:$perm $path",
                logoutput               => true,
                unless                  => "/bin/getfacl $path 2>&1 | /bin/grep ^$type:$user:$perm",
                require => Package['acl'],
                }
        }



}



    package { 'nginx' :
		ensure => installed
	}

    package { 'acl' :
		ensure => installed
	}

    service { 'nginx' : 
		ensure => running, 
		enable => true, 
	}

	
	$wwwdirs = [
	'/__MML_OPT__',
	'/__MML_OPT__/socket',
	'/__MML_OPT__/www',
	]
 
	file { $wwwdirs :
		ensure => directory,
	}
	
	
###########################
# Приводим в порядок 		#
# Контент домена по умолчанию#
###########################
	exec { '/__MML_WORK__/scripts/managedomain.sh  adddom default' :
		require	=> [
			User[NGINX], 
			File[$wwwdirs],
		
		],
		unless	=> '/bin/grep ^fpm.default: /etc/passwd',
		notify	=> Exec['rm default site'],
	}
	
	exec { 'rm default site' :
		refreshonly	=> true,
		command 	=>	"/bin/rm /etc/nginx/sites-enabled/default /etc/nginx/sites-available/default",
	}
	
 	file { 'Content default web site' :
		path	=> 	'/__MML_OPT__/www/default/www',
		source  => 	'__MML_WORK__puppet/nginx/index',
		ensure 	=> 	directory,
		recurse 	=>	'true',
		owner		=> NGINX,
		require 	=> Exec["/__MML_WORK__/scripts/managedomain.sh  adddom default"],
	}
	
##########################
# Создаем пользователя NGINX#
##########################
		user { NGINX:
                ensure            =>  present,
                shell             =>  "/bin/false",
                home              =>  "/dev/null",
                comment           =>  "NGINX USER",
                managehome        =>  false,
                require           =>  Group[NGINX],
        }

        group { NGINX:
        }
		
		
# ###################################
# # Раздаем необходимые права через ACL#
# ###################################
	acl::setacl { '/__MML_OPT__' :
		type	=> "user",
		user 	=> "NGINX",
		perm 	=> "--x", 
		setdefault => true,
		require => [
			User[NGINX],
			File[$wwwdirs],
		]
	}	
	
	acl::setacl { 'default mask www' : 
		dir		=> '/__MML_OPT__/www',
		type	=> "mask",
		user 	=> "",
		perm 	=> "rwx", 
		setdefault 	=> true,
		recursion	=> true,
		require	=> [
			File[$wwwdirs],
			Exec['/__MML_WORK__/scripts/managedomain.sh  adddom default'],
			]
	}

	acl::setacl { 'Mask socket folder' : 
		dir		=> '/__MML_OPT__/socket/',
		type	=> "mask",
		user 	=> "",
		perm 	=> "rwx", 
		setdefault => true,
		recursion	=> true,
		require	=> File[$wwwdirs],
	}
	
	acl::setacl { 'Nginx to socket folder' : 
		dir		=> '/__MML_OPT__/socket/',
		type	=> "user",
		user 	=> "NGINX",
		perm 	=> "rwx", 
		setdefault => true,
		require	=> [
			File[$wwwdirs],
			Acl::Setacl['/__MML_OPT__'],
			Exec['/__MML_WORK__/scripts/managedomain.sh  adddom default'],
			]	
		}

	# ############################################
	# # Включаем необходимые конифигурационные файлы#
	# ############################################
	file { '/etc/nginx/nginx.conf' :
		source  => '__MML_WORK__puppet/nginx/nginx.conf',
		replace =>      true,
		notify  =>      Service["nginx"],
		owner => NGINX,
    }
	
	file { '/etc/nginx/geoip.dat' :
		source  => '__MML_WORK__puppet/nginx/geoip.dat',
		replace =>      true,
		notify  =>      Service["nginx"],
		owner => NGINX,
    }	
	
	file { '/etc/nginx/sites-available/template' :
		source  => '__MML_WORK__puppet/nginx/template',
		replace =>      true,
		notify  =>      Service["nginx"],
		owner 	=> NGINX,
    }
	
 


