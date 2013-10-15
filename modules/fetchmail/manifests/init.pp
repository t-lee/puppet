class fetchmail {
    include stdlib

    $yamlfile = "/etc/puppet-yaml/$name.yaml"

    $fetchmail_data = loadyaml($yamlfile)

    package { 'fetchmail':
        ensure => present,
    }

    file { '/etc/fetchmailrc':
        ensure  => 'present',
        owner   => 'fetchmail',
        group   => 'root',
        mode    => '0600',
        content => template("fetchmail/fetchmailrc.erb"),
        notify  => Service['fetchmail'],
        require => Package['fetchmail'],
    }

    file { '/etc/default/fetchmail':
        ensure  => present,
        source  => 'puppet:///modules/fetchmail/etc/default/fetchmail',
        notify  => Service['fetchmail'],
        require => Package['fetchmail'],
    }

    service { 'fetchmail':
        ensure  => running,
        enable  => true,
        require => [Package['fetchmail'],File['/etc/default/fetchmail','/etc/fetchmailrc']]
    }
}
