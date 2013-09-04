# Class: ganglia::client
#
# This class installs the ganglia client
#
# Parameters:
#   $cluster
#     default unspecified
#     this is the name of the cluster
#
#   $cluster_gmond_address
#     default 10.15.128.217
#     this is the address to publish metrics on
#
#   $owner
#     default unspecified
#     the owner of the cluster
#
#   $send_metadata_interval
#     default 0
#     the interval (seconds) at which to resend metric metadata.
#     If running unicast, this should not be 0
#
#   $cluster_gmond_port
#     default 8649
#     this is the udp port to send metrics to
#
#   $unicast_listen_port
#     default 8649
#     the port to listen for unicast metrics on
#
#   $user
#     default ganglia
#     The user account to be used by the ganglia service
#
# Actions:
#   installs the ganglia client
#
# Sample Usage:
#   include ganglia::client
#
#   or
#
#   class {'ganglia::client': cluster => 'mycluster' }
#
#
class ganglia::client (
  $ensure = 'latest',
  $cluster='common',
  $cluster_gmond_address = '10.15.128.217',
  $owner='devbliss',
  $send_metadata_interval = 60,
  $cluster_gmond_port = '8649',
  $user = 'ganglia',
  ) {

  case $::osfamily {
    'Debian': {
      $ganglia_client_pkg     = 'ganglia-monitor'
      $ganglia_client_service = 'ganglia-monitor'
      $ganglia_lib_dir        = '/usr/lib/ganglia'
      Service[$ganglia_client_service] {
        hasstatus => false,
        status    => "ps -ef | grep gmond | grep ${user} | grep -qv grep"
      }
    }
    'RedHat': {
      # requires epel repo
      $ganglia_client_pkg     = 'ganglia-gmond'
      $ganglia_client_service = 'gmond'
      $ganglia_lib_dir        = $::architecture ? {
        /(amd64|x86_64)/ => '/usr/lib64/ganglia',
        default          => '/usr/lib/ganglia',
      }
    }
    default:  {fail('no known ganglia monitor package for this OS')}
  }

  package {$ganglia_client_pkg:
    ensure => $ensure,
    alias  => 'ganglia_client',
  }
  package {'ganglia-monitor-python':
    ensure => $ensure,
    require => Package[$ganglia_client_pkg];
  }

  service {$ganglia_client_service:
    ensure  => 'running',
    alias   => 'ganglia_client',
    require => Package[$ganglia_client_pkg,ganglia-monitor-python];
  }

  file {'/etc/ganglia/gmond.conf':
    ensure  => present,
    require => Package['ganglia_client'],
    content => template('ganglia/gmond.conf'),
    notify  => Service[$ganglia_client_service];
  }
}
