class pxe {
    include pxe::syslinux
    include pxe::dhcpd
    include pxe::tftpd
}
