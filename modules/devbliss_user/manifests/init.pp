define devbliss_user ($ensure = present, groups = []) {
  $user = $title

  if $ensure == "absent" {
    user { $user:
      ensure => 'absent',
    }
    group { $user:
      ensure => 'absent',
    }
    file { "/home/$user":
      ensure => 'absent',
      recurse => true,
      force => true,
    }
    User[$user] -> Group[$user] -> File["/home/$user"]
  } 
  if $ensure == "present" {
    case $user {
      tboehme: {
        $id = 1001
        $ssh_keyname = "thomas.boehme@devbliss.com"
        $ssh_type    = "ssh-dss"
        $ssh_key     = "AAAAB3NzaC1kc3MAAACBALUUABRUad+WOyT6YIJF5FjVmJhgXkEF5so19KLX9pe4ikxnBWA9yTdG1e87OtFNIxqLh3YG2K8Ruqy9G5ElFJ1hNXHMb+/AtwG2bBVXbw/TR8gJ34AEk57vXBdk4qk6/E0zQ1vNH00eqWaEBVg1EkoTWXU0QYMgTlpkQBCByvmPAAAAFQDNW4atMnLlhz6KpJ3uTjxUi0hWWQAAAIBJC+dRlfcTgk1H+CoH2HU+rUCEe8zciCUwZeI22SjD9UYUYzhC2/tjsh9ljMHaeRXh9iwNPB9/dCk7i6RbtXJo7WvvHXgsMfAdS7pFpkl8Ch0TJzllQrG9mYb3Gujc+Kn4BputtI615rXJ+8LQ7qJSi5ETmBYShpihNqDlSVd1NwAAAIEAnV765WeFBl+ARcXEJXsurB0zV2EbyK+H86WEBx8+TuqpM3IdDqeWIDeXGryufjDdGVk6T5YOYs7eEEs6KDVsRbB0PF/2TunZJ4f+ytl/p1AAkzSBtjE4b0xWv6OAgsmuvZU618dohQXnp1rjnTLwO0WLtvhgQ9M/8JQQsaVzNII="
      }
      ujanssen: {
        $id = 1003
        $ssh_keyname = "uwe.janssen@devbliss.com"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAABJQAAAIBo5/Ww7JVtx2fNJkCsEzmKehB/lEiJaLEkbFTE3D5KaD24akhaak8aPhlA+fDZpfHTooicMcOTtMPDTROy+CTERma/S1FvLtlU8nV1DCc+CyxhLP6ktCoGwGwKhetixvRpItmz6uJ2NXgVUrZL41MfQQ2VlOG4TAQgTEIO3Vtq+w=="
      }
      robinkautz: {
        $id = 1004
        $ssh_keyname = "robinkautz@Robins-MacBook-Pro.local"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCdxSQkS5bEMUJbQ+Pn54oHcicPSwhqC8cKS5pkaBjMIrNHRv4oR8FtArGU6H/LCxyq3BK0G+6HIkW5cvgEny3tVMinhmJDiBR4ZECJXbaSbBfj0QAmO2/+dU5s03+k3gz39Yq41jVfusNFiYtiuN/8g6uKWKWIpW1kNx4zYnBPrrUZt7W/J2MOEvGBJbyW10ttJnz4gyTOsWJ5gATh6SxmjH6dy62Md438YyuUbSAeMKkrxq6lrpU5RxlMZOTJiGT/HJf5PrhmrE65BOnOx3whzAkiJa8xbdj8PtTfNXMqhSs2N7XpQ/7XD5jKw3VEYacmvKsCHNCq6MhGzvrOJ9rv"
      }
      stefanopalazzo: {
        $id = 1005
        $ssh_keyname = "stefanopalazzo@Stefanos-MacBook-Pro.local"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCafRbpS4a5lG4LjglXLshCiQNr6ulNQYYqLqHPKVXkosUmBqZuFFFlzfQbYw/wQOxiXg9QJcT7UHyQkTqLEbxZ8J6aWhUJ2dlqpSOqoxKWmy/6RTAkbgM2VQVeGQo+83ZeRw8zfpyvy/qKFo3Oohu1oqBKGMNQLv1DvKkAvtoy0wGv+tI40XKezZMtxQlK3XUzJBjOsZq1lJoCkXih045WHZ5MJfrWrtZnq40NV7GDNUa1D438+xtCh9PglhOCrGVs0UqLFqK63CDCZ+PYeHH+UsahoCXSf3I3kY+3xoa5J2jRwRKRI2pdSwqWSq74qjP7R6lWWKQXjgQ8YC7WA02Z"
      }
      jenkins: {
        $id = 1006
        $ssh_keyname = "jenkins@d-2.spreegle.de"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQDBePVrHvRJqYch961Ys1MieaLkmQobAmZvA1nvde67zu7vsijECOORC+WrlW9PuZAcM59+8BljdgBAFp28JplMRV9view3rAQjlwMAfuSdmMXLqMRP7kJ59NKMGcGEMu0V+2lk9o3ci5sP6vy8efQJ2tOm6NDBDl1vvB39UXQl3na/3Gtib1vYY4JRyIJUac/WNCZvEaLkC9NV7jFRCdqVRyWPSSK+K1UapoQOAs9pORke8yqSJtuXScADqCFcv9EyA25EnpmImBcQUvvop4O0AEAESelWE7RRumDbaICd58rDHs8UVGhGuDAwcPdtBtYlSm0R9zQKkK4Adk5wXMkJ"
      }
      rstiller: {
        $id = 1007
        $ssh_keyname = "robert.stiller@devbliss.com"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCjkAON7poXVB/RXI91c4w4318r8D+NqOnsfIFeyvuNezsVyrCmbH2yD690nLPWxOH91IihWfD6I52YkN+HLFCt1vSSp6+HLOkWB0XGtuKT21edUu2fNqsrKUfvvPU5QUeflFl/5UkXFpXIzfpwnU49JUDcSlB+auVFEv03VWqA5A04/UlKI+wjFv9NW7VZDXYOfQJrd2b2Q4EGV7cjrOyV0a8mYZWnmzTExqtvd2+PC5GeG6qHGAmCI2vflTRtEnlU5V96mQltAw4L+V0ENSXepuR8YJXM/WEHQtTVzsEwC0jXUhcvBuGiRXu4qHndMlm3+4ZwFW08B0APs61vsKfb"
      }
      rbickel: {
        $id = 1008
        $ssh_keyname = "ralf.bickel@devbliss.com"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCn7wAPJI9TK59ofu/aiMpN0JNtdGdpf6JfI2E3q9vMnFsZAMyrzafcTbkH0xWsS4oc32jCdFT6zpN7h9n/4GWnMOSTf66ZejCjJWoetTXXmKR8LyRWRqag/QbeOXgm6PEBjSE+JuzcD4UKTac/8gmEIB0LK/BakDV6L926n8skxYJGHdDeJbtXtGWgN0frlc53eZenwENElBkIKZzCahj9qqCGG386AJAh7LwQ9es+SRATK7lH97KaVAZwQ3/NRfHig1qjeOIhIpMeq7bwAXo5v12oru4ExNJafbj8+FtGH6HQ08xXXUcNUnwjMtt/g2mPNwmfCmZ5m3zjHZutxobt"
      }
      ptc: {
        $id = 1009
        $ssh_keyname = "ptc@PatBook-Pro.local"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQD0NFVD8AK8A1u93qzFE2W0s5wF8GV3+MxWz/5QUv379b2vzaQwxu6Qv30a+iJVv9BfQFT50GnuVZun14M/IjPn/ukCuuSzkjo0P5qUl8IrIGroZ0akBjLJVFXh5q16L6900OhXwR5m6xyis8aaNpdhsWR4La7LxB7v+67Nyq+fzuRgDNcncUagpROzV9BZ1hiX6F839hBGqGNbEfJlE8aWkLvCmk/hmEwMFVjBdA0wC2Igef/n6ANyNjBfsI4euQQ+s81W4Imi52hOLV7NEXgph/b4XBGzETc2WgSTDlyrAsjlJmFppr46jQNGx6Q+BE2LGz+rRIFaATd6oh7+qATX"
      }
      blissdoc: {
        $id = 1010
        $ssh_keyname = "blissdoc@devbliss.com"
        $ssh_type    = "ssh-rsa"
        $ssh_key     = "AAAAB3NzaC1yc2EAAAADAQABAAABAQCjkAON7poXVB/RXI91c4w4318r8D+NqOnsfIFeyvuNezsVyrCmbH2yD690nLPWxOH91IihWfD6I52YkN+HLFCt1vSSp6+HLOkWB0XGtuKT21edUu2fNqsrKUfvvPU5QUeflFl/5UkXFpXIzfpwnU49JUDcSlB+auVFEv03VWqA5A04/UlKI+wjFv9NW7VZDXYOfQJrd2b2Q4EGV7cjrOyV0a8mYZWnmzTExqtvd2+PC5GeG6qHGAmCI2vflTRtEnlU5V96mQltAw4L+V0ENSXepuR8YJXM/WEHQtTVzsEwC0jXUhcvBuGiRXu4qHndMlm3+4ZwFW08B0APs61vsKfb"
      }
      default: {
        fail("no settings for user '$user' defined")
      }
    }
    
    user { $user:
      ensure     => $ensure,
      managehome => true,
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

    ssh_authorized_key { $user:
      ensure  => $ensure,
      name    => $ssh_keyname,
      type    => $ssh_type,
      key     => $ssh_key,
      user    => $user,
    }
    Group[$user] -> User[$user]
  }
}
