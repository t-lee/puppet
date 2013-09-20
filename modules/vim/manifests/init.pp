class vim {
    package { "vim": ensure => latest }

    file { '/etc/vim/vimrc.local':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => 644,
        source  => "puppet://$puppetserver/modules/vim/vimrc.local",
        require => Package['vim'],
    }
}
