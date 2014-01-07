class mysql::blissdoc {
	exec { "init_blissdoc":
        command => "mysql -e \"create database if not exists blissdoc;\" && \
                    mysql --force blissdoc < /var/blissdoc/blissdoc_schema.sql && \
                    touch /etc/puppet/locks/init_blissdoc.lock",
        path    => "/usr/bin/",
        creates => "/etc/puppet/locks/init_blissdoc.lock"
    }
    
	exec { "init_blissdoc_grants":
        command => "mysql -e \"
            grant all on blissdoc.* to 'blissdoc'@'127.0.0.1' identified by 'blissdoc' WITH GRANT OPTION;
            grant all on blissdoc.* to 'blissdoc'@'localhost' identified by 'blissdoc' WITH GRANT OPTION;
            grant all on blissdoc.* to 'blissdoc'@'%' identified by 'blissdoc' WITH GRANT OPTION;
            flush privileges;\" && \
            touch /etc/puppet/locks/init_blissdoc_grants.lock",
        path    => "/usr/bin/",
        creates => "/etc/puppet/locks/init_blissdoc_grants.lock"
    }

    Exec['init_mysql'] -> Exec['init_blissdoc','init_blissdoc_grants']
}