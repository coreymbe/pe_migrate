class pe_migrate::prep {

  if $facts['os']['family'] == 'RedHat' {
    yumrepo { 'puppet-tools':
      ensure   => present,
      name     => 'puppet-tools',
      baseurl  => "http://yum.puppet.com/puppet-tools/el/${facts['os']['release']['major']}/\$basearch",
      enabled  => '1',
      gpgcheck => '0',
      before   => Package['puppet-bolt'],
    }
    package { 'puppet-bolt':
      ensure   => 'installed',
      provider => yum,
    }
    package { 'rsync':
      ensure     => 'installed',
    }
  }
  elsif $facts['os']['family'] == 'Debian' {
    apt::source { 'puppetlabs':
    ensure         => present,
    location       => 'http://apt.puppetlabs.com',
    repos          => 'puppet-tools',
    release        => $facts['os']['distro']['codename'],
    allow_unsigned => true,
    before         => Package['puppet-bolt'],
    }
    package { 'puppet-bolt':
    ensure   => 'installed',
    provider => apt,
    }
  }
  else {
    warning('This class does not support this OS.')
  }
}
