class smarthost::server {
    include smarthost

    file { "/etc/postfix/main.cf":
      ensure  => present,
      owner   => "root",
      group   => "root",
      mode    => 0644,
      source  => "puppet:///modules/smarthost/main.cf",
      require => Package["postfix"],
      notify  => Service["postfix"],
    }

    file { "/etc/postfix/canonical-sender":
      ensure  => present,
      owner   => "root",
      group   => "root",
      mode    => 0644,
      source  => "puppet:///modules/smarthost/canonical-sender",
      require => Package["postfix"],
    }

    file { "/etc/postfix/canonical-sender.db":
      ensure  => present,
      require => Package["postfix"],
    }

    exec { "postmap /etc/postfix/canonical-sender":
      subscribe   => File["/etc/postfix/canonical-sender","/etc/postfix/canonical-sender.db"],
      refreshonly => true,
      path        => ["/usr/bin", "/usr/sbin"],
      notify      => Service["postfix"],
    }

    file { "/etc/postfix/virtual":
      ensure  => present,
      owner   => "root",
      group   => "root",
      mode    => 0644,
      source  => "puppet:///modules/smarthost/virtual",
      require => Package["postfix"],
    }

    file { "/etc/postfix/virtual.db":
      ensure  => present,
      require => Package["postfix"],
    }

    exec { "postmap /etc/postfix/virtual":
      subscribe   => File["/etc/postfix/virtual","/etc/postfix/virtual.db"],
      refreshonly => true,
      path        => ["/usr/bin", "/usr/sbin"],
      notify      => Service["postfix"],
    }
}

