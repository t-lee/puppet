class pxe::syslinux {
    include pxe::tftpd

    package { 'syslinux-common':
        ensure  => present,
    }

    file { '/var/lib/tftpboot/pxelinux.0':
        ensure  => link,
        target  => '/usr/lib/syslinux/pxelinux.0',
        require => [File['/var/lib/tftpboot'],Package['syslinux-common'],],
    }

    file { '/var/lib/tftpboot/vesamenu.c32':
        ensure  => link,
        target  => '/usr/lib/syslinux/vesamenu.c32',
        require => [File['/var/lib/tftpboot'],Package['syslinux-common']],
    }

    file { '/var/lib/tftpboot/pxelinux.cfg':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => 755,
        require => [File['/var/lib/tftpboot'],Package['syslinux-common']],
    }

    file { '/var/lib/tftpboot/pxelinux.cfg/logo.png':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/pxe/var/lib/tftpboot/pxelinux.cfg/logo.png",
        require => File['/var/lib/tftpboot/pxelinux.cfg'],
    }

    file { '/var/lib/tftpboot/pxelinux.cfg/default':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/pxe/var/lib/tftpboot/pxelinux.cfg/default",
        require => File['/var/lib/tftpboot/pxelinux.cfg'],
    }

    file { '/var/lib/tftpboot/pxelinux.cfg/pxe.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/pxe/var/lib/tftpboot/pxelinux.cfg/pxe.conf",
        require => File['/var/lib/tftpboot/pxelinux.cfg'],
    }

}
