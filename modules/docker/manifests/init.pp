class docker {

  exec { "linux-image-extras":
    command => "apt-get install -y --force-yes linux-image-extra-`uname -r`",
    path => "/usr/bin:/bin",
    logoutput => "on_failure",
  }

  exec { "add-apt-repository -y ppa:dotcloud/lxc-docker":
    creates => "/etc/apt/sources.list.d/dotcloud-lxc-docker-raring.list",
    require => Package["software-properties-common"],
    logoutput => "on_failure",
    path => "/usr/bin",
  } ~> exec { "apt-get update":
    logoutput => "on_failure",
    path => "/usr/bin",
  }

  package { "lxc-docker":
    ensure => installed,
    require => [
                Exec["apt-get update"],
                Exec["linux-image-extras"],
                Exec["add-apt-repository -y ppa:dotcloud/lxc-docker"],
                ],
  }

}
