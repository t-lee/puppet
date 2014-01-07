# Class: mysql
#
# This module manages mysql-server
#
class mysql($config_file = "mysql/my.cnf.erb") {

  package { ['mysql-server', 'mytop']:
    ensure => present,
  }

  service { 'mysql':
    ensure  => running,
    enable  => true,
    require => Package['mysql-server'],
    subscribe => File['/etc/mysql/my.cnf'],
  }

  file { '/etc/mysql/my.cnf':
    content => template("${config_file}"),
    notify  => Service['mysql'],
  }

  file { '/etc/mysql/debian.cnf':
    content => template("mysql/debian.cnf.erb"),
    require => Package['mysql-server'],
  }

  file { "/usr/bin/show-grants":
    source => "puppet://$puppetserver/$environment/modules/mysql/files/show-grants",
    mode => 755,
  }

  file { "/usr/bin/mytop":
    source => "puppet://$puppetserver/$environment/modules/mysql/files/mytop",
    mode => 755,
    require => Package['mytop'],
  }

  exec { "init_mysql":
    command => "mysql -e \"
                DROP DATABASE IF EXISTS test;
                delete from mysql.host;
                delete from mysql.proxies_priv;
                DELETE FROM mysql.user;
                DELETE FROM mysql.db;
                GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
                GRANT USAGE ON *.* TO 'nagios'@'10.15.128.136' IDENTIFIED BY PASSWORD '*82802C50A7A5CDFDEA2653A1503FC4B8939C4047';
                GRANT RELOAD ON *.* TO 'debian-sys-maint'@'localhost' IDENTIFIED BY PASSWORD '*DDFF85E31D9D65BCE009420B16B891F0C13FC566';
                FLUSH PRIVILEGES;\" mysql && \
                touch /etc/puppet/locks/init-mysql.lock",
    path    => "/usr/bin/",
    creates => "/etc/puppet/locks/init-mysql.lock"
  }

   Service['mysql'] -> Exec['init_mysql']
}



