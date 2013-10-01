class group::admins {
    group { "admins":
        ensure   => present,
        gid      => 200,
        system   => true,
    }
}
