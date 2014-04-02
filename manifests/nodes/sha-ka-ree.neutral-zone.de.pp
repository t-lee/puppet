node 'sha-ka-ree.neutral-zone.de' inherits default {
    class {'openvpn':}
    #class {'backup::server':} ### disabled since there is no backup volume attached
    class {'autofs':}
    class {'courier-imap':}
    class {'fetchmail':}
    class {'bind':}
    class {'pxe':}
    class {'pxe::dhcpd':
        domain_name         => "neutral-zone.de",
        domain_name_servers => "192.168.0.1",
        subnet_mask         => "255.255.255.0",
        server_name         => "sha-ka-ree",
        next_server         => "192.168.0.4",
        subnet              => "192.168.0.0",
        netmask             => "255.255.255.0",
        range_start         => "192.168.0.100",
        range_end           => "192.168.0.199",
        routers             => "192.168.0.1" 
    }
    nfs::export {'/var/lib/tftpboot/install':
        host    => '192.168.0.0/24',
        options => 'ro,async,no_root_squash,no_subtree_check' 
    }
    nfs::export {'/media/data/musik': host => '172.18.10.5'}
}
