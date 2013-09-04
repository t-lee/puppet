# Class: backup::gvh
#
# This class includes the backup configuration for gvh-project
#
# Parameters:
#
# Actions:
#
# Sample Usage:
#   include backup::gvh
#
class backup::gvh {
  file {'/usr/sbin/gvh-backup.sh':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0744',
    source  => "puppet:///modules/backup/usr/sbin/gvh-backup.sh",
  }
  file {'/etc/cron.d/gvh-backup':
    ensure   => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/backup/etc/cron.d/gvh-backup",
  }

}
