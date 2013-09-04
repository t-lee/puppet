class ppa::deb-devbliss {
  
  exec { "deb.devbliss.com":
    command => "add-apt-repository 'deb http://deb.devbliss.com/ precise main' && \
                wget -O - http://deb.devbliss.com/gpg/devbliss.gpg.key | apt-key add - && apt-get update && \
                touch /etc/puppet/locks/deb.devbliss.com.lock",

    path => ['/bin', '/usr/bin/'],
    user => root,
    creates => "/etc/puppet/locks/deb.devbliss.com.lock",
    require => Package[wget],
  }
  package { wget: 
  	ensure => present 
  }
}
