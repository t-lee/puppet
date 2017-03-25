# == Class: hosts::install
#
class hosts::install {
  if $::hosts::package_name {
    package { 'hosts':
      ensure => $::hosts::package_ensure,
      name   => $::hosts::package_name,
    }
  }

  if $::hosts::package_list {
    ensure_resource('package', $::hosts::package_list, { 'ensure' => $::hosts::package_ensure })
  }
}
