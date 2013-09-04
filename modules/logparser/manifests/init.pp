# Class: logparser
#
# This module manages logparser
#
class logparser {

  package { 'logparser':
    ensure => latest,
  }
  package { 'python3-distutils':
    ensure => absent,
  }
  file { 'config-file':
    path => '/etc/logparser/local.ini',
    ensure => "present",
    owner  => "root",
    group  => "root",
    mode   => 644,
    require => Package['logparser'],
    notify  => Service['logparser'],
    content => template("logparser/local.ini.erb"),
  }
  service { 'logparser':
    ensure  => running,
    enable  => true,
    require => File['config-file']
  }
}