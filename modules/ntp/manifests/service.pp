class ntp::service {
  if $is_virtual == 'true' {
    service {'ntp':
      ensure => stopped,
      enable => false,
    }
  }
  service { 'ntp':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => Class['ntp::install'],
  }
}
