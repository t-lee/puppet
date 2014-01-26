define nfs::export (
    $host    = undef,
    $options = "rw,sync,no_subtree_check",
){
    include nfs::server

    if $host   == undef { fail("'host' not defined") }

    $_nfs_exports_filename = regsubst($title, '/', '_', 'G')
 
    file { "/etc/exports.d/${_nfs_exports_filename}.exports":
        ensure  => present,
        group   => "root",
        owner   => "root",
        mode    => "0644",
        content => "$title    $host($options)",
        require => [Package[nfs-kernel-server],File['/etc/exports.d']],
        notify  => [Service[nfs-kernel-server]],
    }
}
