# Class: backup::client
#
# This class includes the ssh public key of our backup server to user root's authorized_keys
#
# Parameters:
#
# Actions:
#
# Sample Usage:
#   class {'backup::client':}
#
class backup::client {
    ssh_authorized_key { backup_client:
        ensure  => present,
        name    => "root@sha-ka-ree",
        type    => "ssh-rsa",
        key     => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDgKSDtTWv3jfiTMRC+DO7BVFQ6olg7fBygpKOzrQSxhCfoLmbMhuWqTf7fhU6nAsY3uIjeKlAncWtT/dS8VFzqmgjnVYie4JES8K9JzOH9suYBBqX/Jt/KFDE0sIMKMh1yltT5I5GcSibzMgdN9/F1tTyXAbss46oplVcWhQB/hSiYqS76Rc5qnZm50W4AKZeH0Uaot8zD9FB3P4jHvMPaeCrwtGaLiJ3rK+a+V75btk3H/ps4OuiGnqlOl4wQgE14+mxd7OIXUJ0Mb2e16J4wcszg7bXbQ9WK4+00K5SudNcBGFn32AxKZldEBHuiX32dxCY9RvnOMR9ps+xHrKhv",
        user    => root,
    }
}
