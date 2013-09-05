class nfs::server {

  service { "portmap": 
    enable     => true,
    ensure     => running,
    require => Package[nfs-common],
  }

  package { "nfs-kernel-server": ensure => installed }

  service { "nfs-kernel-server": 
    enable     => true,
    ensure     => running,
    require    => [Service[portmap],Package[nfs-kernel-server]], 
  }

}
