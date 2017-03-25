class vim {
    package { "vim": ensure => latest }

    file { '/etc/vim/vimrc.local':
        ensure  => present,
        owner   => 'root',
        group   => 'root',
        mode    => '644',
        source  => "puppet:///modules/vim/vimrc.local",
        require => Package['vim'],
    }

    # Will also update gem, irb, rdoc, rake, etc.
    alternatives { 'editor':
        path    => '/usr/bin/vim.basic',
        require => Package['vim'],
    }
}
