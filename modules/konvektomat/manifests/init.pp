# installs konvektomat debian package repository service
class konvektomat {
  package { 'konvektomat':
    ensure => 'latest',
  }

  file { '/etc/konvektomat/local.json':
    source  => 'puppet:///modules/konvektomat/local.json',
    require => Package['konvektomat'],
    notify  => Service['konvektomat'],
  }

  file { '/srv/konvektomat/users.list':
    source  => 'puppet:///modules/konvektomat/users.list',
    require => Package['konvektomat'],
    notify  => Service['konvektomat'],
  }

  file { '/srv/konvektomat/conf.in':
    ensure => directory,
  }

  file { '/srv/konvektomat/conf.in/distributions':
    source => 'puppet:///modules/konvektomat/distributions',
  }

  package { "daemon":
  }

  file {'/etc/init.d/konvektomat':
    source => 'puppet:///modules/konvektomat/konvektomat.init',
    mode => 0755,
    require => Package["daemon"],
  }

  service { 'konvektomat':
    ensure  => running,
    enable  => true,
    require => [File['/etc/init.d/konvektomat'], File['/etc/konvektomat/local.json']],
  }

  file { '/srv/konvektomat/public.key':
    source => 'puppet:///modules/konvektomat/kv-public.key',
    require => File['/srv/konvektomat/conf.in'],
  }

  file { '/root/konvektomat-private.key':
    source => 'puppet:///modules/konvektomat/kv-private.key',
    require => File['/srv/konvektomat/conf.in'],
  }

  exec { 'gpg --import /srv/konvektomat/public.key':
    path => '/usr/bin:/bin',
    logoutput => 'on_failure',
    require => File['/srv/konvektomat/public.key'],
    unless => "gpg --list-keys | grep FE2A119E",
  }

  exec { 'gpg --allow-secret-key-import --import /root/konvektomat-private.key':
    path => '/usr/bin:/bin',
    logoutput => 'on_failure',
    require => File['/root/konvektomat-private.key'],
    unless => "gpg --list-secret-keys | grep FE2A119E",
  }

}
