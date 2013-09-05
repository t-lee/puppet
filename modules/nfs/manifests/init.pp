class nfs {
  package { "nfs-common": ensure => latest }

  service { "statd": 
    enable     => true,
    ensure     => running,
    require => Package[nfs-common],
  }

#    mount { "/mnt/devbliss_config":
#        device  => "d-1.spreegle.de:/data/nfs/devbliss_config",
#        fstype  => "nfs",
#        ensure  => "mounted",
#        options => "noatime,rsize=32768,wsize=32768,soft,vers=3",
#        atboot  => true,
#        require => [Package[nfs-common],File["/mnt/devbliss_config"]],
#    }
    
#    file { "/mnt/devbliss_config":
#        ensure => directory,
#        group  => "root",
#        owner  => "root",
#        mode   => "0755",
#    }
        
}
