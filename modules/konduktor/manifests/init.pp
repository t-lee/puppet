# module installing konduktor key server
class konduktor {
    package { 'konduktor':
        ensure => 'latest',
    }

    file { '/etc/konduktor':
      ensure => directory,
    }
    file { '/etc/konduktor/konduktor.ini':
        source  => 'puppet:///modules/konduktor/konduktor.ini',
        require => [Package['konduktor'], File['/etc/konduktor'], ],
        notify  => Service['konduktor'],
    }
    file { '/etc/konduktor/whitelist.list':
        source  => 'puppet:///modules/konduktor/whitelist.list',
        require => [Package['konduktor'], File['/etc/konduktor'], ],
        notify  => Service['konduktor'],
    }
    file { '/etc/konduktor/blacklist.list':
        source  => 'puppet:///modules/konduktor/blacklist.list',
        require => [Package['konduktor'], File['/etc/konduktor'], ],
        notify  => Service['konduktor'],
    }
    file { '/etc/konduktor/trust_whitelist.list':
        source  => 'puppet:///modules/konduktor/trust_whitelist.list',
        require => [Package['konduktor'], File['/etc/konduktor'], ],
        notify  => Service['konduktor'],
    }
    file { '/etc/konduktor/trust_blacklist.list':
        source  => 'puppet:///modules/konduktor/trust_blacklist.list',
        require => [Package['konduktor'], File['/etc/konduktor'], ],
        notify  => Service['konduktor'],
    }


    service { 'konduktor':
        ensure  => running,
        enable  => true,
        require => [File['/etc/konduktor/konduktor.ini'],
                    File['/etc/konduktor/whitelist.list'],
                    File['/etc/konduktor/blacklist.list'],
                    File['/etc/konduktor/trust_whitelist.list'],
                    File['/etc/konduktor/trust_blacklist.list'],
                ],
    }
}
