class nginx {
        package { "nginx" :
                ensure => present
        }

        service { 'nginx' :
                ensure => running,
                enable => true,
                require => Package['nginx'],
        }
}
