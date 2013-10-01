class autofs {
    package { 'autofs':
        ensure => 'present'
    }

    file { '/etc/auto.master':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '644',
        source  => 'puppet:///modules/autofs/auto.master',
        require => Package['autofs'],
    }

    file { '/etc/auto.media':
        ensure  => 'present',
        owner   => 'root',
        group   => 'root',
        mode    => '644',
        source  => 'puppet:///modules/autofs/auto.media',
        require => Package['autofs'],
    }

    service { 'autofs':
        ensure  => running,
        enable  => true,
        require => Package['autofs'],
    }
}
