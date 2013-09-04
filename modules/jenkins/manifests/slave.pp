class jenkins::slave {

    include ppa::fkrull-deadsnakes

    devbliss_user {[jenkins]: 
        ensure  => present,
    }
    package {
        [
          'openjdk-6-jre-headless',
          'git',
          'vagrant',
          'maven',
          'maven2',
          'openjdk-7-jdk',
          'python3',
          'python3-setuptools'
        ]:
        ensure  => present,
    }
    
    package { 'python3.3':
        ensure  => present,
        require => Exec['ppa:fkrull/deadsnakes'],
    }

    file { '/home/jenkins/.ssh/known_hosts':
        ensure  => present,
        owner   => jenkins,
        group   => jenkins,
        mode    => 644,
        source  => "puppet://$puppetserver/$environment/modules/jenkins/files/known_hosts",
    }
    file { '/home/jenkins/.ssh/id_rsa.pub':
        ensure  => present,
        owner   => jenkins,
        group   => jenkins,
        mode    => 644,
        source  => "puppet://$puppetserver/$environment/modules/jenkins/files/id_rsa.pub",
    }
    file { '/home/jenkins/.gitconfig':
        ensure  => present,
        owner   => jenkins,
        group   => jenkins,
        mode    => 664,
        source  => "puppet://$puppetserver/$environment/modules/jenkins/files/gitconfig",
    }
    file { '/home/jenkins/.m2/settings.xml':
        ensure  => present,
        owner   => jenkins,
        group   => jenkins,
        mode    => 664,
        source  => "puppet://$puppetserver/$environment/modules/jenkins/files/settings.xml",
    }

    package { mailutils: ensure => present }

    file { '/home/jenkins/puppet-open-manual-tasks.sh':
        ensure  => present,
        owner   => jenkins,
        group   => jenkins,
        mode    => 755,
        source  => "puppet://$puppetserver/$environment/modules/jenkins/files/puppet-open-manual-tasks.sh",
        require => Package[mailutils],
    }
    exec { "/home/jenkins/puppet-open-manual-tasks.sh":
        command => "/home/jenkins/puppet-open-manual-tasks.sh",
        path    => ['/bin', '/usr/bin/'],
        user    => root,
        creates => "/etc/puppet/locks/puppet-open-manual-tasks.lock",
        require => File['/home/jenkins/puppet-open-manual-tasks.sh'], 
  }
}