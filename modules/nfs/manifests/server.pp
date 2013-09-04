class nfs::server {
  include nfs

  package { "nfs-kernel-server": ensure => installed }

  service { "nfs-kernel-server": 
    enable     => true,
    ensure     => running,
    require    => [Service[portmap],Package[nfs-kernel-server]], 
  }

}
