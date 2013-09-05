class exec-locks {
    file { "/etc/puppet/locks":
        ensure => "directory"
    }
}
