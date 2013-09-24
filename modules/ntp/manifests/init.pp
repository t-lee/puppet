class ntp::server {
  include ntp::install
  include ntp::service

  file { "/etc/ntp.conf":
    content => template("ntp/server.conf.erb"),
    require => Package["ntp"],
    notify => Service["ntp"],
  }
}

class ntp::client {  
  include ntp::install
  include ntp::service

  file { "/etc/ntp.conf":
    source => "puppet://$puppetserver/modules/ntp/files/client.conf",
    require => Package["ntp"],
    notify => Service["ntp"],
  }
}
