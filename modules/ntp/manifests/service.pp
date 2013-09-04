class ntp::service {
  if $is_virtual == 'true' {
    service {'ntp':
      ensure => stopped,
      enable => false,
    }
  }
  if $is_lxc == 'true' {
    service {'ntp':
      ensure => stopped,
      enable => false,
    }
  }
  else {
    service { 'ntp':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
      enable     => true,
      require    => Class['ntp::install'],
    }
  }
}
