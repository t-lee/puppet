class pxe::dhcpd (
    $domain_name = "UNDEF",
    $domain_name_servers = "UNDEF",
    $subnet_mask = "UNDEF",
    $server_name = "UNDEF",
    $next_server = "UNDEF",
    $subnet = "UNDEF",
    $netmask = "UNDEF",
    $range_start = "UNDEF",
    $range_end = "UNDEF",
    $routers = "UNDEF"
) {
    package { 'isc-dhcp-server':
        ensure => present,
    }

    file { '/etc/dhcp/dhcpd.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        #source  => "puppet:///modules/pxe/etc/dhcp/dhcpd.conf",
        content => template("pxe/etc/dhcp/dhcpd.conf.erb"),
        require => Package['isc-dhcp-server'],
        notify  => Service['isc-dhcp-server'],
    }

    service {'isc-dhcp-server':
        ensure => running,
        enable => true,
        require => File['/etc/dhcp/dhcpd.conf'],
    }
}
