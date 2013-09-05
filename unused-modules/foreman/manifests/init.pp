class foreman {
  file { '/etc/sudoers.d/20_foreman':
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template("foreman/etc/sudoers.d/20_foreman.erb"),
  }
  file { '/etc/puppet/autosign.conf':
    owner   => 'foreman-proxy',
    group   => 'foreman-proxy',
  }
}