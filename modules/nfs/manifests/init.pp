class nfs {
  package { "nfs-common": ensure => latest }

  service { "statd": 
    enable     => true,
    ensure     => running,
    require => Package[nfs-common],
  }
}
