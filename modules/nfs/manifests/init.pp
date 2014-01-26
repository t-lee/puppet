class nfs {
    package { "nfs-common": ensure => latest }

    case $::operatingsystem {
        'Debian': {
            $nfs_common_service_name = 'nfs-common'
            $portmap = 'rpcbind'
        }
        'Ubuntu': {
            $nfs_common_service_name = 'statd'
            $portmap = 'portmap'
        }
        default:  {fail('not supported OS')}
    }

    service { "$portmap":
        enable     => true,
        ensure     => running,
    }

    service { "$nfs_common_service_name": 
        enable     => true,
        ensure     => running,
        require    => [Package[nfs-common],Service[$portmap]],
    }
}
