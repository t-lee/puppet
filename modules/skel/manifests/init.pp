class skel {
    file { '/etc/skel/pistore.desktop':
        ensure => absent,
    }
}
