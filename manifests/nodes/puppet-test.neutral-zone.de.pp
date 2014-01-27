node 'puppet-test.neutral-zone.de' inherits default {
    #class {'openvpn':}
    #class {'backup::server':}
    #class {'autofs':}
    #class {'courier-imap':}
    #class {'fetchmail':}
    #class {'bind':}
    class {'pxe':}
    class {'pxe::dhcpd':
        domain_name = "neutral-zone.de",
        domain_name_servers = "192.168.0.4",
        subnet_mask = "255.255.255.0",
        server_name = "puppet-test",
        next_server = "192.168.111.1",
        subnet = "192.168.111.0",
        netmask = "255.255.255.0",
        range_start = "192.168.111.100",
        range_end = "192.168.111.199",
        routers = "192.168.111.1" 
    }
}
