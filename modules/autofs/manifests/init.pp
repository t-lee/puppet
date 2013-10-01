class autofs {
    package { 'autofs':
        ensure => 'present'
    }

    file { '/etc/auto.master.d/':
        ensure  => 'directory',
        owner   => 'root',
        group   => 'root',
        mode    => '755',
        require => Package['autofs'],
    }

    file { '/etc/auto.master.d/backup.autofs':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '644',
        require => File['/etc/auto.master.d/'],
        content => "backup           -fstype=ext4            :/dev/sda1\n",
        notify  => Service['autofs'],
    }

    service { 'autofs':
        ensure  => running,
        enable  => true,
        require => Package['autofs'],
    }
}
