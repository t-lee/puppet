# Class: rsyncd
#
# This module manages rsyncd
#
class rsyncd {

  package { 'rsync':
    ensure => installed,
  }

  $rsync_repository = '/var/rsync_repository'
    file { $rsync_repository:
      ensure => "directory",
      owner  => "jenkins",
      group  => "jenkins",
      mode   => 644,
    }



  file { "/etc/rsyncd.conf":
    source => "puppet://$puppetserver/$environment/modules/rsyncd/files/rsyncd.conf",
    require => Package["rsync"],
    notify => Service[rsync],
  }

  file { "/etc/default/rsync":
    source => "puppet://$puppetserver/$environment/modules/rsyncd/files/rsync",
    require => Package["rsync"],
    notify => Service[rsync],
  }

  service { 'rsync':
    ensure    => running,
    enable    => true,
    require => File["/etc/rsyncd.conf", "/etc/default/rsync", "$rsync_repository"],
  }
}
