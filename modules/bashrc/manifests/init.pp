class bashrc {
  file { '/etc/profile.d/extra.bashrc.sh':
    ensure => present,
    owner  => "root",
    group  => "root",
    mode   => "755",
    source => "puppet:///modules/bashrc/extra.bashrc.sh";
  }

}
