class ntp::install {
  if $is_virtual == 'false' {
    if ! defined(Package['ntp']) {
      package { 'ntp':  ensure => installed }
    }
    if ! defined(Package['ntpdate']) {
      package { 'ntpdate':  ensure => installed }
    }
  }
}
