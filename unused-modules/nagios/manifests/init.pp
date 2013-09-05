class nagios {
  include sms_sender
  include nagios::target
  
  File { 
    ensure => present, 
    owner => "root",
    group => "root",
    mode => 0444,
  }
  
  package {
    "nagios3-cgi":          ensure => present;
    "nagios3":              ensure => present;
    "nagios-nrpe-plugin":   ensure => present;
    "apache2":              ensure => present;
    "libapache2-mod-php5":  ensure => present;
    "build-essential":      ensure => present;
    }
        
  file { "/etc/nagios3/nagios.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/nagios.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/htpasswd.users":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/htpasswd.users",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/cgi.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/cgi.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/conf.d/nexus.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/nexus.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/conf.d/ebookworxs.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/ebookworxs.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/conf.d/www_gvh.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/www_gvh.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/conf.d/commands.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/commands.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/conf.d/contacts.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/contacts.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/conf.d/host_template.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/host_template.cfg",
    require => Package["nagios3"],
  }

  file { "/etc/nagios3/conf.d/service_template.cfg":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/service_template.cfg",
    require => Package["nagios3"],
  }
  
  file { 
    ["/etc/nagios3/conf.d/contacts_nagios2.cfg", 
    "/etc/nagios3/conf.d/localhost_nagios2.cfg", 
    "/etc/nagios3/conf.d//hostgroups_nagios2.cfg",
    "/etc/nagios3/conf.d/services_nagios2.cfg",
    "/etc/nagios3/conf.d/extinfo_nagios2.cfg",
    "/etc/nagios3/conf.d/generic-host_nagios2.cfg",
    "/etc/nagios3/conf.d/generic-service_nagios2.cfg"] :
    ensure => absent,
    require => Package["nagios3"],
  }    

#  exec { "purge_nagios_config":
#    command => "rm -f /etc/nagios3/nagios_host.cfg /etc/nagios3/nagios_service.cfg",
#    path    => "/bin/",
#  }

  file { "/etc/nagios3/nagios_host.cfg":
    mode => 0444,
    notify  => Service["nagios3"],
    #require => Exec['purge_nagios_config'],
  }
  file { "/etc/nagios3/nagios_service.cfg":
    mode => 0444,
    notify  => Service["nagios3"],
    #require => Exec['purge_nagios_config'],
  }
  
  # Fixing "error: Could not stat() command file"
  file { "/var/lib/nagios3":
    mode => 0771,
    owner => "nagios",
    group => "nagios",
    require => Package["nagios3"],
  }
  file { "/var/lib/nagios3/rw":
    mode => 0771,
    owner => "nagios",
    group => "www-data",
    require => Package["nagios3"],
  }
  file { "/var/lib/nagios3/rw/nagios.cmd":
    mode => 0771,
    owner => "nagios",
    group => "www-data",
    require => Package["nagios3"],
  }
  
  service { "nagios3": 
    ensure => "running",
    require => Package["nagios3"]
  }
  

  file { "/etc/apache2/sites-enabled/nagios":
    source => "puppet://$puppetserver/$environment/modules/nagios/files/apache2.conf",
    require => Package["apache2"],
  }
  file { "/etc/apache2/sites-enabled/000-default":
    ensure => absent,
    require => Package["apache2"],
  }
  
  # Collect resources and populate /etc/nagios/nagios_*.cfg
  Nagios_host <<||>>
  Nagios_service <<||>>
}

