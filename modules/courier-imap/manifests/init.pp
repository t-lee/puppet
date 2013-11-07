class courier-imap {
    # gamin is needed to get rid of these errors in email client:
    #   Filesystem notification initialization error -- contact your mail
    #   administrator (check for configuration errors with the FAM/Gamin library)
    package { 'gamin':
        ensure => present,
    }

    package { 'courier-imap-ssl':
        ensure  => present,
        require => Package['gamin'],
    }

    service { 'courier-imap':
        ensure  => stopped,
        enable  => true,
        require => [Package['courier-imap-ssl'],File['/etc/courier/imapd']],
    }

    service { 'courier-imap-ssl':
        ensure  => running,
        enable  => true,
        require => Package['courier-imap-ssl'],
    }

    file { '/etc/courier/imapd':
        ensure => present,
        source => 'puppet:///modules/courier-imap/etc/courier/imapd',
        notify => Service['courier-imap'],
    }
}
