class devbliss::locks {
    file { "/etc/puppet/locks":
        ensure => "directory"
    }
}