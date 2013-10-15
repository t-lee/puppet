class bind {
    package { 'bind9':
        ensure => present,
    }

    service { 'bind9':
        ensure  => running,
        enable  => true,
    }

    file { '/etc/bind/named.conf.options':
        ensure  => present,
        source  => 'puppet:///modules/bind/etc/bind/named.conf.options',
        notify  => Service['bind9'],
        before  => Service['bind9'],
        require => Package['bind9'], 
    }

    file { '/etc/bind/named.conf.local':
        ensure  => present,
        source  => 'puppet:///modules/bind/etc/bind/named.conf.local',
        notify  => Service['bind9'],
        before  => Service['bind9'],
        require => Package['bind9'], 
    }

    file { '/etc/bind/db.0.168.192':
        ensure  => present,
        source  => 'puppet:///modules/bind/etc/bind/db.0.168.192',
        notify  => Service['bind9'],
        before  => Service['bind9'],
        require => Package['bind9'], 
    }
}