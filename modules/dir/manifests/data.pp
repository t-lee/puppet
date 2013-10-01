class dir::data {
    file { '/data':
        ensure => directory,
        owner  => root,
        group  => root,
        mode   => 755,
    }
}
