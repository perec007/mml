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
	'/storage',
	'/storage/socket',
	'/storage/www',
	]
 
	file { $wwwdirs :
		ensure => directory,
	}
	
	
###########################
# Приводим в порядок 		#
# Контент домена по умолчанию#
###########################
	exec { '/root/scripts/managedomain.sh  adddom default' :
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
		path	=> 	'/storage/www/default/www',
		source  => 	'/home/os/mml/puppet/nginx/index',
		ensure 	=> 	directory,
		recurse 	=>	'true',
		owner		=> NGINX,
		require 	=> Exec["/root/scripts/managedomain.sh  adddom default"],
	}
	
##########################
# Создаем пользователя NGINX#
##########################
		user { NGINX:
                ensure            =>  present,
                uid               =>  1000,
                gid               =>  1000,
                shell             =>  "/bin/false",
                home              =>  "/dev/null",
                comment           =>  "NGINX USER",
                managehome        =>  false,
                require           =>  Group[NGINX],
        }

        group { NGINX:
                gid               => 1000,
        }
		
		
# ###################################
# # Раздаем необходимые права через ACL#
# ###################################
	acl::setacl { '/storage' :
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
		dir		=> '/storage/www',
		type	=> "mask",
		user 	=> "",
		perm 	=> "rwx", 
		setdefault 	=> true,
		recursion	=> true,
		require	=> [
			File[$wwwdirs],
			Exec['/root/scripts/managedomain.sh  adddom default'],
			]
	}

	acl::setacl { 'Mask socket folder' : 
		dir		=> '/storage/socket/',
		type	=> "mask",
		user 	=> "",
		perm 	=> "rwx", 
		setdefault => true,
		recursion	=> true,
		require	=> File[$wwwdirs],
	}
	
	acl::setacl { 'Nginx to socket folder' : 
		dir		=> '/storage/socket/',
		type	=> "user",
		user 	=> "NGINX",
		perm 	=> "rwx", 
		setdefault => true,
		require	=> [
			File[$wwwdirs],
			Acl::Setacl['/storage'],
			Exec['/root/scripts/managedomain.sh  adddom default'],
			]	
		}

	# ############################################
	# # Включаем необходимые конифигурационные файлы#
	# ############################################
	file { '/etc/nginx/nginx.conf' :
		source  => '/home/os/mml/puppet/nginx/nginx.conf',
		replace =>      true,
		notify  =>      Service["nginx"],
		owner => NGINX,
    }
	
	file { '/etc/nginx/geoip.dat' :
		source  => '/home/os/mml/puppet/nginx/geoip.dat',
		replace =>      true,
		notify  =>      Service["nginx"],
		owner => NGINX,
    }	
	
	file { '/etc/nginx/sites-available/template' :
		source  => '/home/os/mml/puppet/nginx/template',
		replace =>      true,
		notify  =>      Service["nginx"],
		owner 	=> NGINX,
    }
	
 


