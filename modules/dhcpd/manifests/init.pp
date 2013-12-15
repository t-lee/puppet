class dhcpd {
    package { 'isc-dhcp-server':
        ensure => present,
    }

#    file { '/etc/dhcp/dhcpd.conf':
#        ensure  => present,
#        owner   => 'root',
#        group   => 'root',
#        mode    => 755,
#        source  => "puppet://$puppetserver/modules/openvpn/etc/init.d/firewall",
#        require => File['/etc/openvpn/iptables.rules.d'],
#    }

    service {'isc-dhcp-server':
        ensure => stopped,
        enable => true,
        require => Package['isc-dhcp-server'],
    }
}
