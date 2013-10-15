class smarthost::client {
    include smarthost
    
    file { "/etc/postfix/main.cf":
      ensure => present,
      owner => "root",
      group => "root",
      mode => 0644,
      content => template("smarthost/main.cf.erb"),
      require => Package["postfix"],
      notify  => Service["postfix"];
    }
}
