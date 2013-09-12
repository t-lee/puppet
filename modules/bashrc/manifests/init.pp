class bashrc {
  file { '/etc/profile.d/romulus.bashrc.sh':
    ensure => present,
    owner  => "root",
    group  => "root",
    mode   => 755,
    source => "puppet://$puppetserver/modules/bashrc/files/romulus.bashrc.sh";
  }

}
