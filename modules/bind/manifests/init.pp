class bind {
    package { 'bind9':
        ensure => present,
    }

    service { 'bind9':
        ensure  => running,
        enable  => true,
        require => Package['bind9'],
    }

#    file { '/etc/courier/imapd':
#        ensure => present,
#        source => 'puppet:///modules/courier-imap/etc/courier/imapd',
#        notify => Service['courier-imap'],
#    }
}