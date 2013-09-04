class gvh::wordpress {
    
    package {"mailutils": ensure => present}

    exec { "recover-message":
    command => "/mnt/gvh_config/recover-msg.wp.sh && touch /etc/puppet/locks/gvh_wordpress-recovery.lock",
    path    => "/usr/bin/",
    creates => "/etc/puppet/locks/gvh_wordpress-recovery.lock",
    require => Package['mailutils'],
  }

}