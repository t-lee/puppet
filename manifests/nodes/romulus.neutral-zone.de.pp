node 'romulus.neutral-zone.de' inherits default {
    class {'openvpn':}
    class {'backup::server':}
}
