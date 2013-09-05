class ppa::fkrull-deadsnakes {

  exec { "ppa:fkrull/deadsnakes":
    command => "add-apt-repository ppa:fkrull/deadsnakes && apt-get update",
    path => ['/bin', '/usr/bin/'],
    user => root,
    creates => "/etc/apt/sources.list.d/fkrull-deadsnakes-$lsbdistcodename.list",
  }
}
