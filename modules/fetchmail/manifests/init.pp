class fetchmail {
    include stdlib

    $fetchmail_data = loadyaml("/etc/puppet-yaml/$name.yaml")

    file { '/etc/fetchmailrc'
 

    }
}
