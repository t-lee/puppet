class openssl {
  package { "ruby1.9.1":   
    ensure => present;
  }
  file { "/usr/bin/cert_check":
    source => "puppet://$puppetserver/$environment/modules/openssl/files/cert_check",
    mode => 755,
  }
}