
class epubli {
    
    class backend ($epubli_home) {
        
        Exec    { user   => root, path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin", "/usr/local/bin"], }
        File    { ensure => present, }
        Package { ensure => latest, }
    
        exec { "devbliss-repo-key":
            command     => "wget -O - http://deb.devbliss.com/gpg/devbliss.gpg.key | apt-key add -",
            refreshonly => true,
        }
    
        file { "devbliss-repo-file":
            path    => "/etc/apt/sources.list.d/devbliss.list",
            content => "deb http://deb.devbliss.com/ precise main\ndeb-src http://deb.devbliss.com/ precise main",
            ensure  => present,
            require => Exec[ "devbliss-repo-key" ],
        }
    
        exec { "apt-get_update": command => "apt-get update", require => File[ "devbliss-repo-file" ] }
    
        package {"base_cmd_tools":
            name => [
                "build-essential",
                "debhelper",
                "devscripts",
                "curl",
                "git",
                "htop",
                "landscape-common",
                "lua5.1",
                "python-pip",
                "python-setuptools",
                "python3",
                "python3-setuptools",
                "tree",
                "vim",
                "zsh",
                "daemon",
                "python-software-properties",
                "ruby1.9.3",
                "ruby-bundler",
                "gdebi-core",
                "python-stdeb",
                "python-fail",
                "mysql-server-5.5",
                "python-mysqldb",
            ],
            require => Exec["apt-get_update"],
        }
        
        package { "puppet-pip":            require => Package[ "base_cmd_tools" ], provider => "gem", }
        package { "httpie":                require => Package[ "base_cmd_tools" ], provider => pip, }
        package { "bottle":                require => Package[ "base_cmd_tools" ], provider => pip, }
        
        # INSTALL epubli-autorencockpit
        package { "epubli-autorencockpit": require => Package[ "base_cmd_tools" ], } ->
        
        # LOG FILE ARE IN /VAR/LOG/UPSTART/EPUBLI.LOG
        file { "/etc/init/epubli.conf":
            ensure  => present,
            content => template("epubli/epubli.conf.erb"),
            force   => true,
            owner   => root,
            group   => root,
            mode    => 644,
            require => Package["bottle"],
        } -> exec { "configure-upstart":
            command => "initctl reload-configuration",
            user    => root,
            require => File["/etc/init/epubli.conf"],
        } -> exec { "start-epubli":
            command => "start epubli",
            user    => root,
            require => Exec["configure-upstart"],
        }
        
    }
    
    class frontend {
    }
    
    $epubli_home = $environment ? {
        "development" => '/vagrant/src/usr/local/bin/epubli',
        default       => '/usr/local/bin/epubli',
    }
    
    class { "epubli::backend":
        epubli_home => $epubli_home
    } ->
    class { "epubli::frontend":
        require     => Class[ "backend" ]
    }
    
}
