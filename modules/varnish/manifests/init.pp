class varnish {
	package { "varnish" :
		ensure => present
	}

	service { 'varnish' :
		ensure => running,
		enable => true,
		require => Package['varnish'],
	}
	class gvh {
		file { '/etc/varnish/default.vcl':
			content => template("varnish/default.vcl.erb"),
			notify  => Service['varnish'],
			require => Package['varnish'],
		}
		file { '/etc/default/varnish':
			content => template("varnish/varnish.erb"),
			notify => Service['varnish'],
			require => Package['varnish'],
		}
	}
}
