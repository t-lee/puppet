node 'sha-ka-ree.neutral-zone.de' inherits default {
    class {'openvpn':}
    class {'backup::server':}
    class {'autofs':}
    class {'courier-imap':}
    class {'fetchmail':}
    class {'bind':}
    class {'pxe':}
    nfs::export {'/media/data/musik': host => '172.18.10.5'}
}
