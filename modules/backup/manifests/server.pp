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
  package { [
      libmime-lite-perl,
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
  }

  file {'/etc/cron.d/devbliss-backup':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/backup/etc/cron.d/devbliss-backup",
    notify  => Service['cron'],
  }

  file {'/etc/logrotate.d/devbliss-backup':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/backup/etc/logrotate.d/devbliss-backup",
  }

  file {'/etc/backup':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
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
