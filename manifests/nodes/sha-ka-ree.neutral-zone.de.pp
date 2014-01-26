node 'sha-ka-ree.neutral-zone.de' inherits default {
    class {'openvpn':}
    class {'backup::server':}
    class {'autofs':}
    class {'courier-imap':}
    class {'fetchmail':}
    class {'bind':}
    class {'pxe':}
    nfs::export {'/media/data/musik': host => '192.168.0.4'}
}
