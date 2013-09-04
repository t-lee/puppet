class apt::update {
    exec { "apt get update":
        command => "apt-get update",
        path => ['/bin', '/usr/bin/'],
        user => root,
    }
}