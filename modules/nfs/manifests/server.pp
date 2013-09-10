class nfs::server {

  package { "nfs-kernel-server": ensure => installed }

  service { "portmap": 
    enable     => true,
    ensure     => running,
  }

  service { "nfs-kernel-server": 
    enable     => true,
    ensure     => running,
    require    => [Service[portmap],Package[nfs-kernel-server]], 
  }

}
