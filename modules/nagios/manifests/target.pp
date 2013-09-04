class nagios::target {
  package {
    "nagios-nrpe-server":   ensure => present;
    "nagios-plugins":       ensure => present;
  }

  package { "libnagios-plugin-perl": 
    ensure => present,
    require => Package["nagios-plugins", "nagios-nrpe-server"],
  }

  file { "/etc/nagios/nrpe.cfg":
    owner => "root",
    group => "root",
    mode => 0444,
    source => "puppet://$puppetserver/$environment/modules/nagios/files/nrpe.cfg",
    notify  => Service["nagios-nrpe-server"],
    require => Package["nagios-plugins", "nagios-nrpe-server"],
  }

  file { "/usr/lib/nagios/plugins/check_memory":
    owner => "root",
    group => "root",
    mode => 0755,
    source => "puppet://$puppetserver/$environment/modules/nagios/files/check_memory.pl",
    require => Package["libnagios-plugin-perl"],
  }

  file { "/usr/lib/nagios/plugins/check_puppet_agent_report":
    owner => "root",
    group => "root",
    mode => 0755,
    source => "puppet://$puppetserver/$environment/modules/nagios/files/check_puppet_agent_report",
    require => Package["libnagios-plugin-perl"],
  }

  file { "/usr/lib/nagios/plugins/check_etc_doc":
    owner => "root",
    group => "root",
    mode => 0755,
    source => "puppet://$puppetserver/$environment/modules/nagios/files/check_etc_doc.rb",
    require => Package["libnagios-plugin-perl"],
  }

  file { "/usr/lib/nagios/plugins/check_disk_svz":
    owner => "root",
    group => "root",
    mode => 0755,
    source => "puppet://$puppetserver/$environment/modules/nagios/files/check_disk_svz.pl",
    require => Package["libnagios-plugin-perl"],
  }
    
  file { "/etc/doc":
    owner => "root",
    group => "root",
    ensure => "directory",
  }

  service { "nagios-nrpe-server": 
    ensure => "running",
    require => File["/usr/lib/nagios/plugins/check_memory"]
  }
  
  @@nagios_host { $fqdn:
    ensure => present,
    alias => $hostname,
    address => $ipaddress,
    use => "generic-host",
  }
    
  @@nagios_service { "check_ping_${hostname}":
    check_command => "check_ping!100.0,20%!500.0,60%",
    use => "generic-service",
    host_name => "$fqdn",
    service_description => "ping"
  }

  @@nagios_service { "check_ssh_${hostname}":
    check_command => "check_ssh",
    use => "generic-service",
    host_name => "$fqdn",
    service_description => "ssh"
  }
    
  @@nagios_service { "check_disk_${hostname}":
    check_command => "check_nrpe_1arg!check_disk",
    use => "generic-service",
    host_name => "$fqdn",
    service_description => "disk"
  }
      
  @@nagios_service { "check_swap_${hostname}":
    check_command => "check_nrpe_1arg!check_swap",
    use => "generic-service",
    host_name => "$fqdn",
    service_description => "swap"
  }

  @@nagios_service { "check_memory_${hostname}":
    check_command => "check_nrpe_1arg!check_memory",
    use => "generic-service",
    host_name => "$fqdn",
    service_description => "memory"
  }
  
  @@nagios_service { "puppet_${hostname}":
    check_command => "puppet_master_checks_agent_report",
    use => "generic-service",
    host_name => "$fqdn",
    service_description => "puppet"
  }
  
  @@nagios_service { "check_ntp_time_${hostname}":
    check_command => "check_ntp_time",
    use => "generic-service",
    host_name => "$fqdn",
    service_description => "ntp"
  }
  
  class etc_doc {
    @@nagios_service { "check_etc_doc_${hostname}":
      check_command => "check_etc_doc",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "etc-doc"
    }
  }
  class cis {
    @@nagios_service { "check_cis_http_prod_${hostname}":
      check_command => "check_cis_http_prod",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "cis-prod"
    }
    @@nagios_service { "check_cis_http_test_${hostname}":
      check_command => "check_cis_http_test",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "cis-test"
    }
  }
  class rcdp {
    @@nagios_service { "check_http_prod_${hostname}":
      check_command => "check_rcdp_http_prod",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "rcdp-http-prod"
    }
    @@nagios_service { "check_https_prod_${hostname}":
      check_command => "check_rcdp_https_prod",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "rcdp-https-prod"
    }
    @@nagios_service { "check_http_test_${hostname}":
      check_command => "check_rcdp_http_test",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "rcdp-http-test"
    }
    @@nagios_service { "check_https_test_${hostname}":
      check_command => "check_rcdp_https_test",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "rcdp-https-test"
    }
    @@nagios_service { "check_rcdp_health_prod_${hostname}":
      check_command => "check_rcdp_health_prod",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "rcdp-health-prod"
    }
    @@nagios_service { "check_rcdp_health_test_${hostname}":
      check_command => "check_rcdp_health_test",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "rcdp-health-test"
    }
  }
  class mysql {
    @@nagios_service { "check_mysql_${hostname}":
      check_command => "check_mysql_cmdlinecred!nagios!nagios",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "mysql"
    }
  } 
  class oracle {
    @@nagios_service { "check_oracle_${hostname}":
      check_command => "check_tcp!1521",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "oracle"
    }
  } 
  class http {
    @@nagios_service { "check_http_${hostname}":
      check_command => "check_http",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "http"
    }
  } 
  class nginx {
    @@nagios_service { "check_nginx_${hostname}":
      check_command => "check_http",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "nginx"
    }
  } 
  class apache {
    @@nagios_service { "check_apache_${hostname}":
      check_command => "check_apache",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "apache"
    }
  } 
  class ntp_peer {
    @@nagios_service { "check_ntp_peer_${hostname}":
      check_command => "check_ntp_peer",
      use => "generic-service",
      host_name => "$fqdn",
      service_description => "ntp-peer"
    }
  } 
  class cert_check {
    @@nagios_service { "check_cert_${hostname}":
      check_command => "check_cert",
      use => "long-polling-service",
      host_name => "$fqdn",
      service_description => "cert-check"
    }
  } 
  class etc_doc {
    file { "/etc/doc/README":
      owner => "root",
      group => "root",
      mode => 0444,
      source => "puppet://$puppetserver/$environment/modules/nagios/files/README",
    }
  } 
}
