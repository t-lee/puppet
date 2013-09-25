class openvpn {
    package { 'ruby1.9.1':
        ensure => present,
    }

    file { '/usr/bin/cert_check':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 755,
        source  => "puppet://$puppetserver/modules/openvpn/usr/bin/cert_check",
        require => Package['ruby1.9.1'],
    }

    file { '/etc/cron.d/cert_check':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/openvpn/etc/cron.d/cert_check",
        notify  => Service['cron'],
    }

    file { '/etc/init.d/firewall':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 755,
        source  => "puppet://$puppetserver/modules/openvpn/etc/init.d/firewall",
        require => File['/etc/openvpn/iptables.rules.d'],
    }

    service { 'firewall':
        ensure  => running,
        enable  => true,
        require => File['/etc/init.d/firewall'], 
    }

    package { ['openvpn','pwgen','zip']:
        ensure => present,
    }

    ## needed by /etc/openvpn/easy-rsa/mail-file.pl
    package { 'libmime-lite-perl':
        ensure => present,
    }

    file { '/etc/openvpn/openvpn.conf':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/openvpn/etc/openvpn/openvpn.conf",
        require => Package['openvpn'],
    }

    file { '/etc/openvpn/client.ovpn.tpl':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/openvpn/etc/openvpn/client.ovpn.tpl",
        require => Package['openvpn'],
    }

    file { '/etc/openvpn/ccd':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        recurse => true,
        replace => false,
        source  => "puppet://$puppetserver/modules/openvpn/etc/openvpn/ccd",
        require => Package['openvpn'],
    }

    file { '/etc/openvpn/keys':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '700',
        require => Package['openvpn'],
    }

    file { '/etc/openvpn/easy-rsa':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        source  => "puppet://$puppetserver/modules/openvpn/etc/openvpn/easy-rsa",
        recurse => true,
        require => Package['openvpn','pwgen','zip'],
    }

    file { '/etc/openvpn/iptables.rules.d':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        source  => "puppet://$puppetserver/modules/openvpn/etc/openvpn/iptables.rules.d",
        recurse => true,
        require => Package['openvpn'],
    }

    group { 'openvpn':
        ensure => present,
        system => true,
    }

    user { 'openvpn':
        ensure  => present,
        system  => true,
        shell   => '/bin/false',
        gid     => 'openvpn',
        require => Group['openvpn'], 
    }

    exec { 'create-crl.pem':
        command  => ". /etc/openvpn/easy-rsa/vars ; openssl ca -config /etc/openvpn/easy-rsa/openssl.cnf -gencrl -out /etc/openvpn/crl.pem",
        path     => "/usr/bin/",
        creates  => "/etc/openvpn/crl.pem",
        provider => "shell",
        onlyif   => "test -f /etc/openvpn/keys/ca.key",
        require  => File['/etc/openvpn/keys','/etc/openvpn/easy-rsa'],
    }
}
