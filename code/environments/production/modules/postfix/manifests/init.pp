class postfix{
	service{'sendmail' : 
		ensure => 'stopped',
	}
	
	package{'postfix' :
		ensure => 'present',
	}
	
	file{'/etc/periodic.conf' :
		ensure => 'file',
		source => 'puppet:///modules/postfix/periodic.conf',
		require => Package['postfix'],
	} 
	
	file{'/usr/local/etc/postfix' :
		source => 'puppet:///modules/postfix/postfix',
		recurse => 'true',
		require => Package['postfix'],
	}
	
	file{'/usr/local/etc/ssl/postfix' :
		ensure => 'directory',
		require => Package['postfix'],
	}

	service{'postfix' :
		ensure => 'running',
		subscribe => File['/usr/local/etc/postfix/'],
	}
	
	exec{'execopenssl' :
		path => '/usr/bin',
		command => 'openssl req -passin pass:pass -new -x509 -nodes -out smtpd.pem -keyout smtpd.pem -days 3650 -subj "/CN=www.example.com/O=Example/C=TH/ST=Bangkok/L=Bangkok"',
		cwd => '/usr/local/etc/ssl/postfix',
		require => Package['postfix'],
	}

	file{'/usr/local/etc/postfix/transport' :
		ensure => 'file',
		require => Package['postfix'],
	}

	exec{'postmap /usr/local/etc/postfix/transport':
		path => '/usr/local/sbin',
		require => Package['postfix'],
	}

	file{'/etc/aliases' :
		ensure => 'file',
		source => 'puppet:///modules/postfix/aliases',
		require => Package['postfix'],
	}
	
	exec{'newaliases' :
		path => '/usr/bin',
		subscribe => File['/etc/aliases'],
	}
}	
