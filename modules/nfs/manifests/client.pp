class nfs::client {

    include nfs

    define nfsmount (
        $mountpoint = undef,
        $source     = undef,
        $options    = "noatime,rsize=32768,wsize=32768,soft,vers=3",
        $atboot     = "true",
        $ensure     = "mounted"
    ){
        if $mountpoint == undef { fail("'mountpoint' not defined") }
        if $source == undef { fail("'source' not defined") }
    
        mount { "$mountpoint":
          device  => "$source",
          fstype  => "nfs",
          ensure  => "$ensure",
          options => "$options",
          atboot  => "$atboot",
          require => [Service[statd],Package[nfs-common],File["$mountpoint"]],
        }

        file { "$mountpoint":
          ensure => directory,
          group  => "root",
          owner  => "root",
          mode   => "0755",
        }
    }
}
