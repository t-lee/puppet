# Class: apache::gvh
#
# This module manages apache config for www.holtzbrinck.com
#
class apache::gvh {

    include apache

    package { ['libphp-phpmailer',
               'libphp-simplepie',
               'libphp-snoopy',
               'php5-curl',
               'php5-gd',
               'php5-intl']:
        ensure => present,
        notify => Service['apache2'],
    }

    file { '/var/empty':
        ensure => "directory",
        notify  => Service['apache2'],
    }

    file { '/etc/apache2/apache2.conf':
        ensure => present,
        content => template("apache/apache2.conf.d-gvh.erb"),
        notify  => Service['apache2'],
    }

    file { '/etc/apache2/sites-enabled/000-default':
        ensure => absent,
        notify  => Service['apache2'],
    }

    file { '/etc/apache2/sites-available/www.holtzbrinck.com':
        ensure => present,
        content => template("apache/www.holtzbrinck.com.erb"),
        notify  => Service['apache2'],
    }

    file { '/etc/apache2/sites-enabled/www.holtzbrinck.com':
        ensure  => 'link',
        target  => '/etc/apache2/sites-available/www.holtzbrinck.com',
        notify  => Service['apache2'],
        require => File['/etc/apache2/sites-available/www.holtzbrinck.com'],
    }

    apache_port {'8060':}
    apache_port {'443':}

    apache_module {'rewrite':}
    apache_module {'ssl':}

    file { '/etc/apache2/ssl/holtzbrinck.com.pem':
        ensure => 'present',
        owner  => "root",
        group  => "root",
        mode   => 644,
        require => Package['apache2'],
        notify  => Service['apache2'],
        source => '/mnt/gvh_config/ssl-certs/holtzbrinck.com.pem',
    }
}
