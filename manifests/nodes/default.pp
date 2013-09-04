node default {
    #################################################################
    # create stages and bring them into correct order
    stage { 'devbliss_base': }
    stage { 'devbliss_advanced': }
    stage { 'last': }
    
    Stage['devbliss_base']
    -> Stage['devbliss_advanced']
    -> Stage['main']
    -> Stage['last']

    #################################################################
    ####  STAGE: devbliss_base

    # set hostname
#    class {'hosts':    stage => devbliss_base}
#    class {'hostname': stage => devbliss_base}

#    class {'devbliss::locks':   stage => devbliss_base}
#    class {'ppa':               stage => devbliss_base}
#    class {'ppa::deb-devbliss': stage => devbliss_base}
#    class {'apt::update':       stage => devbliss_base}
        
#    Class['devbliss::locks'] -> Class['ppa'] -> Class['ppa::deb-devbliss'] -> Class['apt::update']
    
    ####  STAGE finished: devbliss_base
    #################################################################

    #################################################################
    ####  STAGE: devbliss_advanced

#    class {'backup::client':          stage => devbliss_advanced}
#    class {'nagios::target':          stage => devbliss_advanced}
#    class {'ganglia::client':         stage => devbliss_advanced}  

#    class {'vim': stage => devbliss_advanced}
    
#    if $fqdn == $mail_relay {
#        class {'smarthost::server': stage => devbliss_advanced}
#    } else {
#        class {'smarthost::client': stage => devbliss_advanced}
#    }
    
#    if $is_virtual == 'false' {
#        if $is_lxc == 'false' {
#            if $fqdn != $ntp_server {
#                class {'ntp::client': stage => devbliss_advanced}
#            }
#        }
#    }

    ####  STAGE finished: devbliss_advanced
    #################################################################


    #################################################################
    ####  STAGE: main (this is the default stage)

#    class {'nfs':}

    # manage sudoers
#    class {'devbliss::admin-group':}
#    class {'sudo':}
#    sudo::conf { 'admins':
#      priority => 10,
#      content  => "%admins ALL=(ALL) NOPASSWD: ALL\n",
#    }
#    Group['admins'] -> Class['sudo']

#    devbliss_user {[tboehme,ujanssen]: 
#        ensure  => present,
#        groups  => ['admins'],
#        require => Group['admins'],
#    }
#    devbliss_user {[njuenemann,ojohn]:
#        ensure => absent,
#    }

#    class {'cron':}

    ####  STAGE finished: main
    #################################################################

    
    #################################################################
    ####  STAGE: last

    ####  STAGE finished: last
    #################################################################
}
