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
    case $fqdn {
        'd-1.spreegle.de',
        'd-2.spreegle.de',
        'd-3.spreegle.de',
        'd-v200.spreegle.de', # puppet und foreman
        'd-v139.spreegle.de', # konduktor.spreegle.de
        'd-v140.spreegle.de', # doc.devbliss.com (new)
        'd-v222.spreegle.de', # nexus.devbliss.com
        'd-v217.spreegle.de', # ganglia.spreegle.de
        'd-v218.spreegle.de',
        'd-v131.spreegle.de', # jenkins.devbliss.com',
        'd-13.spreegle.de': {
            $ensure = 'present'
        }
        default: {
            $ensure = 'absent'
        }
    }
    ssh_authorized_key { backup_client:
        ensure  => $ensure,
        name    => "root@backup.spreegle.de",
        type    => "ssh-dss",
        key     => "AAAAB3NzaC1kc3MAAACBAIPfgMYzjT6oE+1KXcVEDwdSo1nuHOyu01hWZ74ji5mOmLgiKkRNCRDve3DbY0H/gaw5yMF9TP06oB31Mzcmu3lDjQ8P0rCg+CdWBpU59sdIvwjw4tgiH6hYqUwX2/ynFixidGmIZTXbJB5bF6wU/huNxAwIHqVUjfOui4bqQeZ7AAAAFQDc0B3kBFrBcLOeIBrLTBOKPyrqhQAAAIACwXhhQEIzAvClAiVkKkXALtGjIw4OUsELze2Q6QUiOiicVIzXc9bYV8f9XRnMkBiB/ezEwmPgNWCRBRmumhIlNxnP8n3yB6dyvYBv2k8QOeAn4rfiadNkfBW91uuSrwCZJwnv7gb3sJzB05h56+X6SLvpZYkFj3fzI/WCzegWgQAAAIB9oUMFsuBMaePgOJAiQ94MeOTpbyXEXtYDfT8X6umaI76ttR3vU6FMcKHnSMjxZ+XiIhusvZ7DbQafcKc+FAj/ckzhQHBAhvcv3pFq5tCMIbwmVVlaY5Oqu+UietEFLPqiUL2Uc6ZtwIDN5+06/EmAfw80oXHK47PLvI1wych5eQ==",
        user    => root,
    }
}
