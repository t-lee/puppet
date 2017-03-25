# == Class: hosts::config
#
class hosts::config {
  if $::hosts::config_dir_source {
    file { 'hosts.dir':
      ensure  => $::hosts::config_dir_ensure,
      path    => $::hosts::config_dir_path,
      force   => $::hosts::config_dir_purge,
      purge   => $::hosts::config_dir_purge,
      recurse => $::hosts::config_dir_recurse,
      source  => $::hosts::config_dir_source,
      require => $::hosts::config_file_require,
    }
  }

  if $::hosts::config_file_path {
    file { 'hosts.conf':
      ensure  => $::hosts::config_file_ensure,
      path    => $::hosts::config_file_path,
      owner   => $::hosts::config_file_owner,
      group   => $::hosts::config_file_group,
      mode    => $::hosts::config_file_mode,
      source  => $::hosts::config_file_source,
      content => $::hosts::config_file_content,
      require => $::hosts::config_file_require,
    }
  }
}
