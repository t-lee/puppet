# Class: hostname
#
# This module manages hostname
#
# Actions:
#   modifies /etc/hostname with facter output
#
# Requires:
#   Nothing
#
# Sample Usage:
#   class { 'hostname': }
#
# [Remember: No empty lines between comments and class definition]
class hostname{
  file { '/etc/hostname':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $::hostname,
  }
}
