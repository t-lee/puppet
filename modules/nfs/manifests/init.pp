class nfs {
  package { "nfs-common": ensure => latest }

  case $::operatingsystem {
    'Debian': {
      $nfs_common_service_name = 'nfs-common'
    }
    'Ubuntu': {
      $nfs_common_service_name = 'statd'
    }
    default:  {fail('not supported OS')}
  }

  service { "$nfs_common_service_name": 
    enable     => true,
    ensure     => running,
    require => Package[nfs-common],
  }
}
