puppet_modules
==============

Our puppet modules used in the environments main, development and testing.


Puppet Master environments in puppet.conf
-----------------------------------------

    [main]
      modulepath = /etc/puppet/modules
      manifest = /etc/puppet/manifests/site.pp
    [development]
      modulepath = /etc/puppet/environments/development/modules
      manifest = /etc/puppet/environments/development/manifests/site.pp
    [testing]
      modulepath = /etc/puppet/environments/testing/modules
      manifest = /etc/puppet/environments/testing/manifests/site.pp
      

  
In `/etc/puppet` do a `git clone https:/github.com/devbliss/puppet_modules modules`.
In `/etc/puppet/environments/development/` and `/etc/puppet/environments/testing/` dito.