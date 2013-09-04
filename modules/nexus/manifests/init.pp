class nexus {
        package { "nexus" :
                ensure => present
        }

        service { 'nexus' :
                ensure => running,
                enable => true,
        }

        class devbliss {
                file { '/etc/nexus/nexus/nexus.xml':
                        content => template("nexus/nexus.xml.erb"),
                        notify => Service['nexus'],
                        owner => "nexus",
                        group => "nexus", 
                }
                file { '/etc/nexus/nexus/security.xml':
                        content => template("nexus/security.xml.erb"),
                        notify => Service['nexus'],
                        owner => "nexus",
                        group => "nexus", 
                }
                file { '/etc/nexus/nexus/security-configuration.xml':
                        content => template("nexus/security-configuration.xml.erb"),
                        notify => Service['nexus'],
                        owner => "nexus",
                        group => "nexus", 
                }
                file { '/opt/nexus/conf/nexus.properties':
                        content => template("nexus/nexus.properties.erb"),
                        notify => Service['nexus'],
                        owner => "nexus",
                        group => "nexus", 
                }

			class nginx {
				file { '/etc/nginx/sites-available/nexus':
					content => template("nexus/nexus.erb"),
					notify => Service['nginx'],
				}
			}
#			class permissions {
#				file { "/var/lib/nexus": 
#					ensure => directory, 
#					owner => "nexus", 
#					group => "nexus", 
#					recurse => true 
#				} 
#				file { "/opt/nexus": 
#					ensure => directory, 
#					owner => "nexus", 
#					group => "nexus", 
#					recurse => true 
#				} 
#				file { "/var/log/nexus": 
#					ensure => directory, 
#					owner => "nexus", 
#					group => "nexus", 
#					recurse => true 
#				} 
#			}
        }
}
