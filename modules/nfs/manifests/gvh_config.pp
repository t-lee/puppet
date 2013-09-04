class nfs::gvh_config {

    include nfs

    mount { "/mnt/gvh_config":
      device  => "d-13.spreegle.de:/var/data/nfs/gvh_config",
      fstype  => "nfs",
      ensure  => "mounted",
      options => "noatime,rsize=32768,wsize=32768,soft,vers=3",
      atboot  => true,
      require => [Service[portmap],Package[nfs-common],File["/mnt/gvh_config"]],
    }
    
    file { "/mnt/gvh_config":
      ensure => directory,
      group  => "root",
      owner  => "root",
      mode   => "0755",
    }
}
