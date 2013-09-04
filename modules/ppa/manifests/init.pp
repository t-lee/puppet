class ppa {
  case $::lsbdistcodename {
    'raring': {
      $software_properties_pkg = 'software-properties-common'
    }
    default: {
      $software_properties_pkg = 'python-software-properties'
    }
  }
  package { $software_properties_pkg: 
  	ensure => present 
  }
}
