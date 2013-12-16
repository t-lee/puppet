class pxe::syslinux {
    package { 'syslinux-common':
        ensure => present,
    }
}
