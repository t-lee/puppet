node 'puppet-test.neutral-zone.de' inherits default {
    #class {'openvpn':}
    #class {'backup::server':}
    #class {'autofs':}
    #class {'courier-imap':}
    #class {'fetchmail':}
    #class {'bind':}
    class {'pxe':}
}
