class smarthost {

  exec { "stop_sendmail":
    command => "sendmail stop",
    path => ["/etc/init.d", "/usr/bin"],
    onlyif => "test -f /etc/init.d/sendmail",
  }
  package { ["sendmail", "sendmail-cf", "sendmail-base", "sendmail-bin", "sendmail-doc"]:
    ensure => purged,
    require => Exec["stop_sendmail"],
  }

  package { "postfix": 
    ensure => present,
    require => Exec["stop_sendmail"],
  }
    
  # Ensure that the postfix service is installed and running.
  # Restart the service if main.cf changes.
  service { "postfix":
    enable  => "true",
    ensure  => "running",
    require => Package["postfix"],
  }
  
  # Rerun newaliases and restart postfix if aliases updated.
  exec { newaliases: 
    command => "/usr/bin/newaliases ; service postfix restart",
    subscribe => File["/etc/aliases"],
    notify => Service["postfix"],
  	refreshonly => true,
  }
        
  file { "/etc/aliases":
    owner => "root",
    group => "root",
    mode => 0644,
    source => "puppet://$puppetserver/$environment/modules/smarthost/files/aliases",
    require => Package["postfix"],
    notify  => Service["postfix"];
  }

  class client {
    include smarthost
    
    file { "/etc/postfix/main.cf":
      owner => "root",
      group => "root",
      mode => 0644,
      content => template("smarthost/main.cf.erb"),
      require => Package["postfix"],
      notify  => Service["postfix"];
    }
  }

  class server {
    include smarthost
    file { "/etc/postfix/main.cf":
      owner => "root",
      group => "root",
      mode => 0644,
      source => "puppet://$puppetserver/$environment/modules/smarthost/files/main.cf",
      require => Package["postfix"],
      notify  => Service["postfix"];
    }
    file { "/etc/postfix/virtual":
      owner => "root",
      group => "root",
      mode => 0644,
      source => "puppet://$puppetserver/$environment/modules/smarthost/files/virtual",
    }
    exec { "postmap virtual":
      subscribe   => File["/etc/postfix/virtual"],
      refreshonly => true,
      path => ["/usr/bin", "/usr/sbin"]
    }
    file { "/etc/postfix/generic":
      owner => "root",
      group => "root",
      mode => 0644,
      source => "puppet://$puppetserver/$environment/modules/smarthost/files/generic",
    }
    exec { "postmap generic":
      subscribe   => File["/etc/postfix/generic"],
      refreshonly => true,
      path => ["/usr/bin", "/usr/sbin"]
    }
  }
}

