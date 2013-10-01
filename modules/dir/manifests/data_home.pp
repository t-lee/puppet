class dir::data::home {
    include dir::data
    file { '/data/home':
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 755,
        require => File['/data'],
    }
}
