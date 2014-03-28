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
    ssh_authorized_key { backup_client_sha_ka_ree:
        ensure  => present,
        name    => "root@sha-ka-ree",
        type    => "ssh-rsa",
        key     => "AAAAB3NzaC1yc2EAAAADAQABAAABAQDgKSDtTWv3jfiTMRC+DO7BVFQ6olg7fBygpKOzrQSxhCfoLmbMhuWqTf7fhU6nAsY3uIjeKlAncWtT/dS8VFzqmgjnVYie4JES8K9JzOH9suYBBqX/Jt/KFDE0sIMKMh1yltT5I5GcSibzMgdN9/F1tTyXAbss46oplVcWhQB/hSiYqS76Rc5qnZm50W4AKZeH0Uaot8zD9FB3P4jHvMPaeCrwtGaLiJ3rK+a+V75btk3H/ps4OuiGnqlOl4wQgE14+mxd7OIXUJ0Mb2e16J4wcszg7bXbQ9WK4+00K5SudNcBGFn32AxKZldEBHuiX32dxCY9RvnOMR9ps+xHrKhv",
        user    => root,
    }
    ssh_authorized_key { backup_client_romulus:
        ensure  => present,
        name    => "root@romulus",
        type    => "ssh-dss",
        key     => "AAAAB3NzaC1kc3MAAACBANP912xB5rcCDB6s8BWm6J0sV/dDATsxPe7CAsH6OcWcDAK2kx78GFAtDudzT6UlqooKSxV8m9k4ym046atw/DdDIEolMttM4lFzRTs5IN7a0GU3dSUN46gptyhtbN3t6jCjwTKySZM7xBfJm+7qaHl6BUU+ZDrU/pAdtcr5azndAAAAFQCAsobMAEI3xdT0wNxTiTXIEzCnkwAAAIEAh9EfYTVvsJd4XK7avhWJsR2+4gZF7epUWcVX0UstIrsARlD2HsatgnqynbVNcVtJCfxDi/aP+blgtikAl6wQ0qy1NHcCjiHccH0+3fnIOBcykJBKV3Zir6YlgGIxlRv91MrU0H9NlXDkE8TCZ/Oer65GgW/baVg1K3Y++IxKv/EAAACAbdKSVNJ0/l7u1oD4L6b/WQubgq5pMSnWGvaGrEd72PbNaSgbfDSWdRfoiMb5fBeIfH/goTrX499eABPUyLG8hZtZVIXUHXIwOacK++OHmuyM74kvdV6w0EnT85UcfcTbMzqwazJn5hYt00i+UsoaZ20saL25nZg3f45DK1BIlxA=",
        user    => root,
    }
}
