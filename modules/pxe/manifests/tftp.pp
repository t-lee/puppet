class pxe::tftpd {
    package { 'tftpd-hpa':
        ensure => present,
    }

    file { '/etc/default/tftpd-hpa':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/dhcpd/etc/default/tftpd-hpa",
        before => Package['tftpd-hpa'],
        notify  => Service['tftpd-hpa'],
    }

    service {'tftpd-hpa':
        ensure => running,
        enable => true,
        require => Package['tftpd-hpa'],
    }
}
