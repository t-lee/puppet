class puppet::master {
  file {'/etc/cron.d/puppet-git':
    ensure  => 'present',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    source  => "puppet:///modules/puppet/puppet-git",
    notify  => Service['cron'],
  }
}