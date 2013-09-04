# Class: apache
#
# This module manages apache
#
class apache {

  package { 'apache2':
    ensure => present,
  }

  package { ['php5', 'php-apc', 'php5-mysql', 'libapache2-mod-php5']:
    ensure  => present,
    require => Package['apache2'],
  }

  service { 'apache2':
    ensure  => running,
    enable  => true,
    require => Package['apache2'],
  }

  file { '/etc/apache2/ports.conf':
    ensure => "present",
    owner  => "root",
    group  => "root",
    mode   => 644,
    require => Package['apache2'],
    notify  => Service['apache2'],
    source => "puppet://$puppetserver/$environment/modules/apache/files/ports.conf";
  }

  file { '/etc/apache2/ssl':
    ensure  => "directory",
    owner   => "root",
    group   => "root",
    mode    => 644,
    require => Package['apache2'],
  }
  
  # health-check
  #
  file { '/etc/apache2/sites-available/8082_health-check':
    content => template("apache/8082_health-check.erb"),
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/sites-enabled/8082_health-check':
    ensure  => 'link',
    target  => '/etc/apache2/sites-available/8082_health-check',
    notify  => Service['apache2'],
    require => File['/etc/apache2/sites-available/8082_health-check'],
  }

  apache_port {'8082':}

  define apache_port ( $apache_port = $title ) {
      file { "/etc/apache2/conf.d/port.${apache_port}.conf":
        ensure => "present",
        owner  => "root",
        group  => "root",
        mode   => 644,
        require => Package['apache2'],
        notify  => Service['apache2'],
        content => template("apache/ports.erb"),
      }
  }

  define apache_module ( $apache_module = $title ) {
      exec { "/etc/apache2/mods-enabled/${apache_module}.conf":
          command => "ln -s ../mods-available/${apache_module}.conf /etc/apache2/mods-enabled/${apache_module}.conf",
          creates => "/etc/apache2/mods-enabled/${apache_module}.conf",
          onlyif  => "test -f /etc/apache2/mods-available/${apache_module}.conf",
          path    => ['/bin', '/usr/bin/'],
          require => Package['apache2'],
          notify  => Service['apache2'],
      }

      exec { "/etc/apache2/mods-enabled/${apache_module}.load":
          command => "ln -s ../mods-available/${apache_module}.load /etc/apache2/mods-enabled/${apache_module}.load",
          creates => "/etc/apache2/mods-enabled/${apache_module}.load",
          onlyif  => "test -f /etc/apache2/mods-available/${apache_module}.load",
          path    => ['/bin', '/usr/bin/'],
          require => Package['apache2'],
          notify  => Service['apache2'],
      }
  }



}
