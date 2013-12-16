class pxe::syslinux {
    include pxe::tftpd

    package { 'syslinux-common':
        ensure  => present,
    }

    file { '/var/lib/tftpboot/pxelinux.0'
        ensure  => link,
        target  => '/usr/lib/syslinux/pxelinux.0'
        require => File['/var/lib/tftpboot'],
        require => Package['syslinux-common'],
    }

    file { '/var/lib/tftpboot/pxelinux.cfg':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => 755,
        require => File['/var/lib/tftpboot'],
        require => Package['syslinux-common'],
    }

}
