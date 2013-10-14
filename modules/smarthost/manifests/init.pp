class smarthost {

  exec { "stop_sendmail":
    command => "sendmail stop",
    path => ["/etc/init.d", "/usr/bin"],
    onlyif => "test -f /etc/init.d/sendmail",
  }
  exec { "stop_nullmailer":
    command => "/etc/init.d/nullmailer stop",
    path => ["/etc/init.d", "/usr/bin", "/usr/sbin", "/bin", "/sbin"],
    onlyif => "test -f /etc/init.d/nullmailer",
  }
  package { ["sendmail", "sendmail-cf", "sendmail-base", "sendmail-bin", "sendmail-doc", "nullmailer"]:
    ensure  => purged,
    require => Exec["stop_sendmail","stop_nullmailer"],
    before  => Package['postfix'],
  }

  package { "postfix": 
    ensure => present,
  }
    
  service { "postfix":
    enable  => "true",
    ensure  => "running",
    require => Package["postfix"],
  }
  
  # Rerun newaliases and restart postfix if aliases updated.
  exec { newaliases: 
    command     => "/usr/bin/newaliases",
  	refreshonly => true,
  	path        => ['/usr/bin','/usr/sbin'], 
    subscribe   => File["/etc/aliases"],
    notify      => Service["postfix"],
  }
        
  file { "/etc/aliases":
    ensure  => present,
    owner   => "root",
    group   => "root",
    mode    => 0644,
    source  => "puppet:///modules/smarthost/aliases",
    require => Package["postfix"],
  }
}

