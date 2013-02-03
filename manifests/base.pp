file { "/etc/apt/sources.list.d/squeeze-backports.list":
    ensure  => file,
    owner   => root,
    group   => root,
    content => "deb http://backports.debian.org/debian-backports squeeze-backports main",
}

file { "/etc/apt/sources.list.d/squeeze-php54.list":
    ensure  => file,
    owner   => root,
    group   => root,
    content => "deb http://packages.dotdeb.org/ squeeze-php54 all",
}

exec { "import-gpg":
    command => "/usr/bin/wget -q http://www.dotdeb.org/dotdeb.gpg -O -| /usr/bin/apt-key add -"
}

exec { "/usr/bin/apt-get update":
    require => [File["/etc/apt/sources.list.d/squeeze-backports.list"], Exec["import-gpg"]],
}

exec { "/usr/bin/dpkg -P php5-suhosin":
    require => Package["php5"],
}


class { "system": }

file { "/etc/motd":
    ensure  => file,
    mode    => "0644",
    owner   => "root",
    group   => "root",
    content => template("system/motd.erb"),
}

            system::package { "build-essential": }
                system::package { "curl": }
                system::package { "git-core": }
                system::package { "vim": }
                system::package { "python": }
        system::package { "g++": }
        system::package { "make": }
        system::package { "wget": }
        system::package { "tar": }

        class { "nodejs":
            version => "v0.8.0"
        }

        package { "bower":
            provider => npm
        }
                system::package { "yui-compressor": }
    
system::config { "bashrc":
    name   => ".bashrc",
    source => "/vagrant/files/system/bashrc",
}


class { "apache": }

class { "apache::mod::php":
    require => Package["php5"]
}


apache::mod { "rewrite": }
apache::mod { "headers": }

apache::vhost { "symfony2.local":
    priority    => "50",
    vhost_name  => "*",
    port        => "80",
    docroot     => "/var/www/vhosts/symfony2.local/web",
    serveradmin => "admin@symfony2.local",
    template    => "system/apache-default-vhost.erb",
    override    => "All",
}

file { "phpmyadmin-vhost-creation":
    path    => "/etc/apache2/sites-enabled/phpmyadmin.conf",
    ensure  => "/vagrant/files/apache/sites-enabled/phpmyadmin.conf",
    require => [Package["php5"], Package["apache2"]],
    owner   => "root",
    group   => "root",
}


class { "mysql":
    root_password => "root",
    require       => Exec["apt-update"],
}


class { "php": }

file { "php5-ini-apache2-config":
    path    => "/etc/php5/apache2/php.ini",
    ensure  => "/vagrant/files/php/php.ini",
    require => Package["php5"],
}

file { "php5-ini-cli-config":
    path    => "/etc/php5/cli/php.ini",
    ensure  => "/vagrant/files/php/php-cli.ini",
    require => Package["php5"],
}

php::module { "mysql": }
php::module { "intl": }
php::module { "cli": }
php::module { "imagick": }
php::module { "gd": }
php::module { "xsl": }
php::module { "mcrypt": }
php::module { "curl": }
php::module { "xdebug": }
php::module { "imap": }
php::module { "apc": }
php::module { "sqlite": }

class { "pear": }

pear::package { "PEAR": }
pear::package { "PHPUnit": }
pear::package { "PHP_CodeSniffer": }


# pear::channel { "phpunit":
#     url => "pear.phpunit.de",
# }
# 
# pear::channel { "symfony2":
#     url     => "pear.symfony.com",
#     require => Exec["pear-channel-phpunit"],
# }
# 
# pear::channel { "symfony1":
#     url     => "pear.symfony-project.com",
#     require => Exec["pear-channel-symfony2"],
# }
# 
# pear::channel { "components":
#     url     => "components.ez.no",
#     require => Exec["pear-channel-symfony1"],
# }

system::package { "phpmyadmin":
    require => Package["php5"]
}


vcsrepo { "vim-config":
    path     => "/home/vagrant/.vim-config",
    ensure   => present,
    provider => git,
    source   => "https://github.com/stephpy/vim-config.git",
    require  => Package["vim"],
    user     => "vagrant",
    group    => "vagrant",
}

file { "vim-config-symlink-vimdir":
    path    => "/home/vagrant/.vim/",
    ensure  => link,
    target  => "/home/vagrant/.vim-config/.vim/",
    require => Vcsrepo["vim-config"],
    owner   => "vagrant",
    replace => false,
}

file { "vim-config-symlink-vimrcfile":
    path    => "/home/vagrant/.vimrc",
    ensure  => link,
    target  => "/home/vagrant/.vim-config/.vimrc",
    require => Vcsrepo["vim-config"],
    owner   => "vagrant",
    replace => false,
}

file { "vim-config-viminfo-file":
    path    => "/home/vagrant/.viminfo",
    content => "",
    require => Vcsrepo["vim-config"],
    owner   => "vagrant",
    replace => false,
}

file { "vim-config-bundle-dir":
    path    => "/home/vagrant/.vim/bundle",
    ensure  => directory,
    require => Vcsrepo["vim-config"],
    owner   => "vagrant",
    replace => false,
}

vcsrepo { "vim-config-vundle":
    path     => "/home/vagrant/.vim/bundle/vundle",
    ensure   => present,
    provider => git,
    source   => "https://github.com/gmarik/vundle.git",
    require  => File["vim-config-bundle-dir"],
    user     => "vagrant",
    group    => "vagrant",
}

# exec { "vim-make-command-t":
#     command => "rake make",
#     cwd     => "/home/vagrant/.vim/bundle/Command-T",
#     unless  => "ls -aFlh /home/vagrant/.vim/bundle/Command-T|grep 'command-t.recipe'",
#     require => Vcsrepo["vim-config-vundle"]
# }

exec { "vim-config-vundle-install":
    command => "vim +BundleInstall! +BundleClean +qall",
    cwd     => "/home/vagrant/.vim",
    path    => "/bin:/usr/bin",
    require => Vcsrepo["vim-config-vundle"],
    user    => "vagrant",
    group   => "vagrant",
}


class { "composer":
    command_name => "composer",
    target_dir   => "/usr/local/bin",
    auto_update  => true
}


system::package { "zsh": }

exec { "oh-my-zsh-install":
    command => "git clone https://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh",
    path    => "/bin:/usr/bin",
    require => Package["zsh"],
}

exec { "default-zsh-shell":
    command => "chsh -s /usr/bin/zsh vagrant",
    unless  => "grep -E \"^vagrant.+:/usr/bin/zsh$\" /etc/passwd",
    require => Package["zsh"],
    path    => "/bin:/usr/bin",
}

file { "zshrc-file-creation":
    path    => "/home/vagrant/.zshrc",
    ensure  => "/vagrant/files/.zshrc",
    require => Exec["oh-my-zsh-install"],
    owner   => "vagrant",
    group   => "vagrant",
    replace => false,
}


