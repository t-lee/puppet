class disco_agent {
  package { disco:
    ensure => "latest"
  }
  
  # fix for spam mails
  file { "/etc/cron.d/disco":
    source => "puppet://$puppetserver/$environment/modules/disco_agent/files/disco",
    require => Package["disco"],
  }
}
