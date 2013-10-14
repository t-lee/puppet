define manage_user ($ensure = present, managehome = false, groups = []) {
  $user = $title

  if $ensure == "absent" {
    user { $user:
      ensure     => 'absent',
      managehome => $managehome,
    }
    group { $user:
      ensure  => 'absent',
      require => User[$user], 
    }
    #file { "/home/$user":
    #  ensure  => 'absent',
    #  recurse => true,
    #  force   => true,
    #  require => Group[$user], 
    #}
  } 
  if $ensure == "present" {
    case $user {
      tommy: {
        $id = 1001
        $ssh_keyname = "tommy@romulus"
        $ssh_type    = "ssh-dss"
        $ssh_key     = "AAAAB3NzaC1kc3MAAACBAML+T/Ben6uA9J6OFseee77a3C3bX9zzBkGxvt806Y5DKQOf3rfbpJAVKWT/T7abYZid2prRuBr+lavvIIa5dA0Yv9V3FeBhnFld3Re4wLGpGSYnmzsgB0OgHjQwIZP5DogH9uOz/3oAYlNi/cobGJXzliocWmmamApM5SPBiYO7AAAAFQDppF4ZxTRqQRnQxQHWLud3EpfaxwAAAIEAsPb8/IN2hsoCY445aUkfKkWq+N0DQvBnIFjo6udpPsHv42O8Uv6CpsTcjF17yPc15B7hL2jbfqvU3NM0Ss3BpW84hoKAPnhZiLe68B5bfPUFz9QPRvNDd4LYA6v3Ot2txtS0DJO4i9z93g2u7CL0CBr2T59ujgeElMRqGodhZ7QAAACAfivUdhfsxUOOK6lJv3w5U51XBb1/usRhWYIH2T18RxtlzKaSe+j54c2EaJGctBSzrYfbXeUmAQVtWKB8zbu/Pip9vnj8a49kscYBeg3lffymWrLkvx1lIONTNMwjbS7DDA0Rd3RbZwVcr02fIrX82grSpEpxoRCd7m99CyJ+Cvw="
      }
      pi: {
        $id = 1000
        $ssh_keyname = ""
        $ssh_type    = ""
        $ssh_key     = ""
      }
      default: {
        fail("no settings for user '$user' defined")
      }
    }
    
    user { $user:
      ensure     => $ensure,
      home       => "/data/home/$user",
      managehome => $managehome,
      uid        => $id,
      shell      => '/bin/bash',
      gid        => $user,
      system     => false,
      groups     => $groups,
    }

    group { $user:
      ensure     => $ensure,
      gid        => $id,
      system     => false,
    }

    if $ssh_key != "" and $ssh_type != "" and $ssh_keyname != "" {
      ssh_authorized_key { $user:
        ensure  => $ensure,
        name    => $ssh_keyname,
        type    => $ssh_type,
        key     => $ssh_key,
        user    => $user,
      }
    }
    Group[$user] -> User[$user]
  }
}
