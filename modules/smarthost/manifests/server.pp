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

    exec { "postmap canonical-sender":
      subscribe   => File["/etc/postfix/canonical-sender"],
      refreshonly => true,
      path        => ["/usr/bin", "/usr/sbin"],
      notify      => Service["postfix"],
    }
}

