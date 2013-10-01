node default {
    #################################################################
    # create stages and bring them into correct order
    stage { 'base': }
    stage { 'avanced': }
    stage { 'last': }
    
    Stage['base']
    -> Stage['avanced']
    -> Stage['main']
    -> Stage['last']

    #################################################################
    ####  STAGE: base

    # set hostname
    class {'hosts':    stage => base}
    class {'hostname': stage => base}

    class {'apt::update':  stage => base}
#    class {'exec-locks':   stage => base}
    
    ####  STAGE finished: base
    #################################################################

    #################################################################
    ####  STAGE: avanced

    class {'backup::client':          stage => avanced}

    class {'vim': stage => avanced}
    
#    if $fqdn == $mail_relay {
#        class {'smarthost::server': stage => avanced}
#    } else {
#        class {'smarthost::client': stage => avanced}
#    }
    
    if $is_virtual == 'false' {
        if $is_lxc == 'false' {
            if $fqdn != $ntp_server {
                class {'ntp::client': stage => avanced}
            }
        }
    }

    ####  STAGE finished: advanced
    #################################################################


    #################################################################
    ####  STAGE: main (this is the default stage)

    class {'bashrc':}

    # manage sudoers
    class {'admin-group':}
    class {'sudo':}
    sudo::conf { 'admins':
      priority => 10,
      content  => "%admins ALL=(ALL) NOPASSWD: ALL\n",
    }
    Class['admin-group'] -> Class['sudo']

    manage_user {[tommy]: 
        ensure  => present,
        groups  => ['admins'],
        require => Group['admins'],
    }
    devbliss_user {[pi]:
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
