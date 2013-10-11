class smarthost::server {
    include smarthost

    file { "/etc/postfix/main.cf":
      owner => "root",
      group => "root",
      mode => 0644,
      source => "puppet:///modules/smarthost/main.cf",
      require => Package["postfix"],
      notify  => Service["postfix"];
    }
    file { "/etc/postfix/virtual":
      owner => "root",
      group => "root",
      mode => 0644,
      source => "puppet:///modules/smarthost/virtual",
    }
    exec { "postmap virtual":
      subscribe   => File["/etc/postfix/virtual"],
      refreshonly => true,
      path => ["/usr/bin", "/usr/sbin"],
      notify  => Service["postfix"],
    }
    file { "/etc/postfix/generic":
      owner => "root",
      group => "root",
      mode => 0644,
      source => "puppet:///modules/smarthost/generic",
    }
    exec { "postmap generic":
      subscribe   => File["/etc/postfix/generic"],
      refreshonly => true,
      path => ["/usr/bin", "/usr/sbin"],
      notify  => Service["postfix"],
    }
}

