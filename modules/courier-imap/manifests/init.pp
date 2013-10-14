class courier-imap {
    package { 'courier-imap-ssl':
        ensure => present,
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
