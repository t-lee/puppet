class lxc::host {
    package { [ lxc, debootstrap, bridge-utils, vlan ]:
        ensure => present,
    }
    service { [ lxc, lxc-net]:
        ensure  => running,
        enable  => true,
        require => [Package[lxc], File[/etc/default/lxc] ],
    }
    file { /etc/default/lxc:
        ensure  => present,
        source  => "puppet://$puppetserver/$environment/modules/lxc/files/default.lxc,
        require => Package[lxc],
        notify  => Service[lxc, lxc-net],
    }
}