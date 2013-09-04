class blissdoc {

    class blissdoc_users {
        
        group { [ "documentators", "resin" ]:
            system => true,
        }
        
        user { "resin":
            groups => ['sudo', 'documentators'],
            system => true,
        }
        
        devbliss_user {[blissdoc]:
            ensure  => present,
            groups  => ['sudo', 'documentators'],
        } ->
        
        file { "/home/blissdoc":
            ensure => directory,
        } ->
        
        file { "/home/blissdoc/.ssh":
            ensure => directory,
        } ->
        
        file { "/home/blissdoc/.ssh/ssh_config":
            source => "puppet:///modules/blissdoc/ssh_config",
        }
        
    }
    
    class blissdoc_files {
        
        file { "/etc/init.d/resin":
            source => "puppet:///modules/blissdoc/resin",
            mode   => 0755,
        }
        file { "/etc/resin/resin.xml":
            source => "puppet:///modules/blissdoc/resin.xml",
        }
        file { "/etc/resin/app-default.xml":
            source => "puppet:///modules/blissdoc/app-default.xml",
        }
        file { "/etc/blissdoc/log4j.xml":
            source => "puppet:///modules/blissdoc/log4j.xml",
        }
        file { "/etc/blissdoc/setting.properties":
            source => "puppet:///modules/blissdoc/setting.properties",
            notify => Service['resin'],
        }
        file { "/etc/blissdoc/META-INF/hosts/doc.devbliss.com.json":
            source => "puppet:///modules/blissdoc/doc.devbliss.com.json",
        }
        file { "/usr/local/share/resin/lib/mysql-connector-java.jar":
            target => "/usr/share/java/mysql-connector-java.jar",
            ensure => link,
            owner => root,
        }
        file_line { ensure_java_home:
            path => "/etc/environment",
            line => "JAVA_HOME=/usr/lib/jvm/java-7-openjdk-amd64/",
        }
        
    }
    
    class pear {
        
        Exec { user => root, path => ['/bin', '/usr/bin/'], }
        
        exec { "upgrade-pear":
            command => "pear upgrade-all && touch '/etc/puppet/locks/pear-upgrade-pear.lock'",
            creates => '/etc/puppet/locks/pear-upgrade-pear.lock',
        } -> exec { "discover":
            command => "pear channel-discover pear.phpdoc.org; true && touch '/etc/puppet/locks/pear-discover.lock'",
            creates => '/etc/puppet/locks/pear-discover.lock',
        } -> exec { "clear-cache":
            command => "pear clear-cache; true && touch '/etc/puppet/locks/pear-clear-cache.lock'",
            creates => '/etc/puppet/locks/pear-clear-cache.lock',
        } -> exec { "update-channels":
            command => "pear update-channels; true && touch '/etc/puppet/locks/pear-update-channels.lock'",
            creates => '/etc/puppet/locks/pear-update-channels.lock',
        } -> exec { "install-phpdoc":
            command => "pear install phpdoc/phpDocumentor-2.0.0a12; true && touch '/etc/puppet/locks/pear-install-phpdoc.lock'",
            creates => '/etc/puppet/locks/pear-install-phpdoc.lock',
        }
        
    }

    exec { "apt-add-repository ppa:natecarlson/maven3 && apt-get update && touch /etc/puppet/locks/ppa.natecarlson.maven3.lock":
        user => root,
        path => ['/bin', '/usr/bin/'],
        creates => '/etc/puppet/locks/ppa.natecarlson.maven3.lock',
    } ->
    
    package { [
        "devbliss-blissdoc",
        "devbliss-blissdoc-doc-builder",
        "devbliss-blissdoc-repository-handler",
        "blissdoc-frontend",
        "resin",
        "libmysql-java"
    ]:
        ensure => latest,
        notify => Service['resin'],
    } ->
    
    package { [
        "openjdk-6-jdk",
        "openjdk-6-jre",
        "openjdk-6-jre-lib",
        "openjdk-6-jre-zero",
        "openjdk-6-source",
        "openjdk-6-doc",
        "openjdk-6-dbg",
        "openjdk-6-demo",
        "openjdk-6-headless-jre",
    ]:
        ensure => absent,
    } ->
    
    class{ 'mysql':
        config_file => "mysql/blissdoc.cnf.erb",
    } ->
    class{ ['blissdoc_files', 'blissdoc_users', 'mysql::blissdoc', 'pear']:
    }
    
    service {'apache2':
        ensure  => stopped,
        enable  => false,
    } ->
    
    service {'resin':
        ensure => running,
        enable  => true,
        require => Class['blissdoc_files', 'blissdoc_users', 'mysql::blissdoc'],
    }
    
}
