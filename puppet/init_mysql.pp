

$mysql = [ 'mysql-client', 'mysql-server', 'apg', ]
	 
	package { $mysql :
		ensure => installed
	}
	
 
	
	

#################################################
# Запускаем базу Устанавливаем дефолтный пароль #
#################################################
	service { 'mysql' : 
		ensure 	=> 	running, 
		enable 	=> 	true, 
		require =>	[ 
			Package[$mysql],
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
##################################################		

	
	file { '/root/.my.cnf' :
		mode	=> 0400,
		owner	=> 'root',
	}

