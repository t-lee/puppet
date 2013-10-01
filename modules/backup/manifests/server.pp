# Class: backup::server
#
# This class includes the backup configuration for gvh-project
#
# Parameters:
#
# Actions:
#
# Sample Usage:
#   include backup::server
#
class backup::server {
  ## needed by /usr/bin/backup_hosts.pl
  include perl::libmime-lite-perl

  package { [
      libproc-processtable-perl,
      libparallel-forkmanager-perl,
      libconfig-inifiles-perl,
      libdate-manip-perl
    ]:
    ensure => present,
    before => File['/usr/bin/backup_hosts.pl'],
  }

  file {'/usr/bin/backup_hosts.pl':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    source  => "puppet:///modules/backup/usr/bin/backup_hosts.pl",
    require => Package['libmime-lite-perl'],
  }

  file {'/etc/cron.d/backup':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/backup/etc/cron.d/backup",
    notify  => Service['cron'],
  }

  file {'/etc/logrotate.d/backup':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/backup/etc/logrotate.d/backup",
  }

  file {'/etc/backup':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
  
  file {'/root/.ssh':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
  }
  
  file {'/root/.ssh/config':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "StrictHostKeyChecking no\n",
  }
  
  file {'/var/log/backup':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file {"/etc/backup/backup_hosts.cfg":
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("backup/backup_hosts.erb"),
    require => File['/etc/backup'],
  }
}
