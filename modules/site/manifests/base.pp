class site::base {
    # set hostname
    include hosts
    include hostname

#    class {'apt::update':  stage => base}
#    class {'exec-locks':   stage => base}
    
###    class {'backup::client':          stage => advanced}

    include vim
    include skel

###    if $fqdn == $mail_relay {
###        class {'smarthost::server': stage => advanced}
###    } else {
###        class {'smarthost': stage => advanced}
###    }
###    
###    if $is_virtual == 'false' {
###        if $fqdn != $ntp_server {
###            class {'ntp::client': stage => advanced}
###        }
###    }
###
###    class { 'group::indiecity': stage  => advanced}
###    class { 'dir::data::home':  stage  => advanced}

    include bashrc

    # manage sudoers
#    class {'group::admins':}
    class {'sudo':}
#    sudo::conf { 'admins':
#      priority => 10,
#      content  => "%admins ALL=(ALL) NOPASSWD: ALL\n",
#    }
#    Class['group::admins'] -> Class['sudo']



    manage_user {[tommy]: 
        ensure  => present,
        groups  => ['sudo'],
        require => Class['sudo'],
    }
    manage_user {[pi]:
        ensure => absent,
    }

###    class {'cron':}
}






