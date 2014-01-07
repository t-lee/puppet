class pxe::dhcpd {
    package { 'isc-dhcp-server':
        ensure => present,
    }

    file { '/etc/dhcp/dhcpd.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet:///modules/pxe/etc/dhcp/dhcpd.conf",
        require => Package['isc-dhcp-server'],
        notify  => Service['isc-dhcp-server'],
    }

    service {'isc-dhcp-server':
        ensure => running,
        enable => true,
        require => File['/etc/dhcp/dhcpd.conf'],
    }
}
