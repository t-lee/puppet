class mysql::gvh {
	exec { "init_gvh_grants":
        command => "mysql -e \" 
                create database if not exists gvh_wordpress;
				GRANT ALL PRIVILEGES ON gvh_wordpress.* TO 'gvh_wordpress'@'localhost';
				GRANT ALL PRIVILEGES ON gvh_wordpress.* TO 'ia'@'localhost';
				GRANT FILE ON *.* TO 'gvh_wordpress'@'localhost' IDENTIFIED BY PASSWORD '*394F17D263BE3D31B4E6C2BA7426503BABCE20B5';
				GRANT USAGE ON *.* TO 'ia'@'localhost' IDENTIFIED BY PASSWORD '*CDFBE54EFE8BE4A9721665ABB40DE0A61E449F9E';
                FLUSH PRIVILEGES;\" mysql && \
                touch /etc/puppet/locks/init_gvh_grants.lock",
        path    => "/usr/bin/",
        creates => "/etc/puppet/locks/init_gvh_grants.lock"
    }

    Exec['init_mysql'] -> Exec['init_gvh_grants']
}