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


    package { 'acl' :
		ensure => installed
	}
	
}



$mysql = [ 'mysql-client-5.5', 'mysql-server-5.5', 'apg', ]
	 
	package { $mysql :
		ensure => installed
	}
	
 
	
	$storagemysql = [
		'/storage/',
		'/storage/mysql/',
		'/storage/mysql/log',
		'/storage/mysql/mysql',
	]
	
	file { $storagemysql :
		ensure => directory,
	}
	
	
	acl::setacl { '/storage/mysql/' :
		type	=> "user",
		user 	=> "mysql",
		perm 	=> "rwx", 
		setdefault => true,
		recursion	=> true,
		require 	=> [
			File[$storagemysql],
			Package[$mysql],
						]
	}


#################################################
# Запускаем базу Устанавливаем дефолтный пароль #
#################################################
	service { 'mysql' : 
		ensure 	=> 	running, 
		enable 	=> 	true, 
		require =>	[ 
			Acl::Setacl["/storage/mysql/"],
			Exec['/bin/cp -p /home/os/mml/puppet/mysql/my.cnf /etc/mysql/my.cnf'],
		],
	}
	

	exec { 'Change mysql password' :
#		refreshonly =>	true,
		unless		=> "/usr/bin/test -f /root/.my.cnf",
		path   		=> 	"/bin:/sbin:/usr/bin:/usr/local/percona/bin:/usr/sbin:/bin",
		command		=> 	 '/bin/bash -c "b=\$(apg -n 1 -m 10 -x 15) && echo \"[client]\" >> /root/.my.cnf && echo \"host=127.0.0.1\" >> /root/.my.cnf &&	echo \"password=\$b\" >> /root/.my.cnf && mysqladmin --password=\'\' --host=127.0.0.1 password \$b"',
		logoutput	=> true,
		subscribe	=> Service['mysql'],
		notify		=>	File['/root/.my.cnf'],
	}




##################################################
# Обязательно проверяем права  на файл с паролем #
# И необходимость замены основного конфига		 #
##################################################		

 	exec { '/bin/cp -p /home/os/mml/puppet/mysql/my.cnf /etc/mysql/my.cnf' :
		unless	=> '/bin/grep -q PUPPET /etc/mysql/my.cnf',
	}	
	
	file { '/root/.my.cnf' :
		mode	=> 0400,
		owner	=> 'root',
	}

