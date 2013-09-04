class sms_sender {
  package { "ruby1.9.3": ensure => present }
  
  file { "/opt/sms_sender":
    owner => "root",
    group => "nagios",
    mode => 770,
    ensure => "directory",
    require => Package["ruby1.9.3"],
  }
  file { "/var/log/sms_sender":
    owner => "root",
    group => "nagios",
    mode => 770,
    ensure => "directory",
    require => Package["ruby1.9.3"],
  }
  file { "/var/lib/sms_sender":
    owner => "root",
    group => "nagios",
    mode => 770,
    ensure => "directory",
    require => Package["ruby1.9.3"],
  }

  file { "/opt/sms_sender/send_sms.rb":
    owner => "root",
    group => "nagios",
    mode => 750,
    source => "puppet://$puppetserver/$environment/modules/sms_sender/files/send_sms.rb",
    require => File["/opt/sms_sender"],
  }
}
