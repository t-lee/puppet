node default {
    #################################################################
    # create stages and bring them into correct order
    stage { 'base': }
    stage { 'advanced': }
    stage { 'last': }
    
    Stage['base']
    -> Stage['advanced']
    -> Stage['main']
    -> Stage['last']

    #################################################################
    ####  STAGE: base

    # set hostname
    class {'hosts':    stage => base}
    class {'hostname': stage => base}

#    class {'apt::update':  stage => base}
#    class {'exec-locks':   stage => base}
    
    ####  STAGE finished: base
    #################################################################

    #################################################################
    ####  STAGE: advanced

    class {'backup::client':          stage => advanced}

    class {'vim':  stage => advanced}
    class {'skel': stage  => advanced}

    if $fqdn == $mail_relay {
        class {'smarthost::server': stage => advanced}
    } else {
        class {'smarthost': stage => advanced}
    }
    
    if $is_virtual == 'false' {
        if $is_lxc == 'false' {
            if $fqdn != $ntp_server {
                class {'ntp::client': stage => advanced}
            }
        }
    }

    class { 'group::indiecity': stage  => advanced}
    class { 'dir::data::home':  stage  => advanced}

    ####  STAGE finished: advanced
    #################################################################


    #################################################################
    ####  STAGE: main (this is the default stage)

    class {'bashrc':}

    # manage sudoers
    class {'group::admins':}
    class {'sudo':}
    sudo::conf { 'admins':
      priority => 10,
      content  => "%admins ALL=(ALL) NOPASSWD: ALL\n",
    }
    Class['group::admins'] -> Class['sudo']

    manage_user {[tommy]: 
        ensure  => present,
        groups  => ['admins'],
        require => Group['admins'],
    }
    manage_user {[pi]:
        ensure => absent,
    }

    class {'cron':}

    ####  STAGE finished: main
    #################################################################

    
    #################################################################
    ####  STAGE: last

    ####  STAGE finished: last
    #################################################################
}

