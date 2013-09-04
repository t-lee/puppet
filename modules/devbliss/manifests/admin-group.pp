class devbliss::admin-group {
    group { "admins":
        ensure   => present,
        gid      => 200,
        system   => true,
    }
}
