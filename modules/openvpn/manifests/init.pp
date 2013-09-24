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

    package { 'openvpn':
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
        mode    => '755',
        require => Package['openvpn'],
    }

    file { '/etc/openvpn/keys':
        ensure  => directory,
        owner   => 'root',
        group   => 'root',
        mode    => '755',
        require => Package['openvpn'],
    }

    file { '/etc/openvpn/easy-rsa':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        source  => "puppet://$puppetserver/modules/openvpn/etc/openvpn/easy-rsa",
        recurse => true,
        require => Package['openvpn'],
    }

    file { '/etc/openvpn/iptables.rules.d':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        source  => "puppet://$puppetserver/modules/openvpn/etc/openvpn/iptables.rules.d",
        recurse => true,
        require => Package['openvpn'],
    }

#sudo addgroup --system --no-create-home --disabled-login --group openvpn
#sudo adduser --system --no-create-home --disabled-login --ingroup openvpn openvpn 

    group { 'openvpn':
        ensure => present,
        system => true,
    }
}
