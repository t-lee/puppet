class nfs::server {

    include nfs

    package { "nfs-kernel-server": ensure => installed }

    service { "nfs-kernel-server": 
        enable     => true,
        ensure     => running,
        require    => [Package[nfs-kernel-server],Service[$nfs::nfs_common_service_name]], 
    }

    file { "/etc/exports.d":
        ensure => directory,
        group  => "root",
        owner  => "root",
        mode   => "0755",
    }
}
