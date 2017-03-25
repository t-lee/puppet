# hosts

[![Build Status](https://travis-ci.org/dhoppe/puppet-hosts.png?branch=master)](https://travis-ci.org/dhoppe/puppet-hosts)
[![Code Coverage](https://coveralls.io/repos/github/dhoppe/puppet-hosts/badge.svg?branch=master)](https://coveralls.io/github/dhoppe/puppet-hosts)
[![Puppet Forge](https://img.shields.io/puppetforge/v/dhoppe/hosts.svg)](https://forge.puppetlabs.com/dhoppe/hosts)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/dhoppe/hosts.svg)](https://forge.puppetlabs.com/dhoppe/hosts)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/dhoppe/hosts.svg)](https://forge.puppetlabs.com/dhoppe/hosts)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/dhoppe/hosts.svg)](https://forge.puppetlabs.com/dhoppe/hosts)

#### Table of Contents

1. [Overview](#overview)
1. [Module Description - What the module does and why it is useful](#module-description)
1. [Setup - The basics of getting started with hosts](#setup)
    * [What hosts affects](#what-hosts-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with hosts](#beginning-with-hosts)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
1. [Limitations - OS compatibility, etc.](#limitations)
1. [Development - Guide for contributing to the module](#development)

## Overview

This module configures the Hosts file.

## Module Description

This module handles configuring Hosts across a range of
operating systems and distributions.

## Setup

### What hosts affects

* hosts configuration file.

### Setup Requirements

* Puppet >= 3.0
* Facter >= 1.6
* [Extlib module](https://github.com/voxpupuli/puppet-extlib)
* [Stdlib module](https://github.com/puppetlabs/puppetlabs-stdlib)

### Beginning with hosts

Install hosts with the default parameters ***(No configuration files will be changed)***.

```puppet
    class { 'hosts': }
```

Install hosts with the recommended parameters.

```puppet
    class { 'hosts':
      config_file_template => "hosts/${::lsbdistcodename}/etc/hosts.erb",
    }
```

## Usage

Update the hosts package.

```puppet
    class { 'hosts':
      package_ensure => 'latest',
    }
```

Remove the hosts package.

```puppet
    class { 'hosts':
      package_ensure => 'absent',
    }
```

Purge the hosts package ***(All configuration files will be removed)***.

```puppet
    class { 'hosts':
      package_ensure => 'purged',
    }
```

Deploy the configuration files from source directory.

```puppet
    class { 'hosts':
      config_dir_source => "puppet:///modules/hosts/${::lsbdistcodename}/etc",
    }
```

Deploy the configuration files from source directory ***(Unmanaged configuration
files will be removed)***.

```puppet
    class { 'hosts':
      config_dir_purge  => true,
      config_dir_source => "puppet:///modules/hosts/${::lsbdistcodename}/etc",
    }
```

Deploy the configuration file from source.

```puppet
    class { 'hosts':
      config_file_source => "puppet:///modules/hosts/${::lsbdistcodename}/etc/hosts",
    }
```

Deploy the configuration file from string.

```puppet
    class { 'hosts':
      config_file_string => '# THIS FILE IS MANAGED BY PUPPET',
    }
```

Deploy the configuration file from template.

```puppet
    class { 'hosts':
      config_file_template => "hosts/${::lsbdistcodename}/etc/hosts.erb",
    }
```

Deploy the configuration file from custom template ***(Additional parameters can
be defined)***.

```puppet
    class { 'hosts':
      config_file_template     => "hosts/${::lsbdistcodename}/etc/hosts.erb",
      config_file_options_hash => {
        'key' => 'value',
      },
    }
```

Deploy additional configuration files from source, string or template.

```puppet
    class { 'hosts':
      config_file_hash => {
        'hosts.2nd' => {
          config_file_path   => '/etc/hosts.2nd',
          config_file_source => "puppet:///modules/hosts/${::lsbdistcodename}/etc/hosts.2nd",
        },
        'hosts.3rd' => {
          config_file_path   => '/etc/hosts.3rd',
          config_file_string => '# THIS FILE IS MANAGED BY PUPPET',
        },
        'hosts.4th' => {
          config_file_path     => '/etc/hosts.4th',
          config_file_template => "hosts/${::lsbdistcodename}/etc/hosts.4th.erb",
        },
      },
    }
```

## Reference

### Classes

#### Public Classes

* hosts: Main class, includes all other classes.

#### Private Classes

* hosts::install: Handles the packages.
* hosts::config: Handles the configuration file.

### Parameters

#### `package_ensure`

Determines if the package should be installed. Valid values are 'present',
'latest', 'absent' and 'purged'. Defaults to 'present'.

#### `package_name`

Determines the name of package to manage. Defaults to 'undef'.

#### `package_list`

Determines if additional packages should be managed. Defaults to 'undef'.

#### `config_dir_ensure`

Determines if the configuration directory should be present. Valid values are
'absent' and 'directory'. Defaults to 'directory'.

#### `config_dir_path`

Determines if the configuration directory should be managed. Defaults to '/etc'

#### `config_dir_purge`

Determines if unmanaged configuration files should be removed. Valid values are
'true' and 'false'. Defaults to 'false'.

#### `config_dir_recurse`

Determines if the configuration directory should be recursively managed. Valid
values are 'true' and 'false'. Defaults to 'true'.

#### `config_dir_source`

Determines the source of a configuration directory. Defaults to 'undef'.

#### `config_file_ensure`

Determines if the configuration file should be present. Valid values are 'absent'
and 'present'. Defaults to 'present'.

#### `config_file_path`

Determines if the configuration file should be managed. Defaults to '/etc/hosts'

#### `config_file_owner`

Determines which user should own the configuration file. Defaults to 'root'.

#### `config_file_group`

Determines which group should own the configuration file. Defaults to 'root'.

#### `config_file_mode`

Determines the desired permissions mode of the configuration file. Defaults to '0644'.

#### `config_file_source`

Determines the source of a configuration file. Defaults to 'undef'.

#### `config_file_string`

Determines the content of a configuration file. Defaults to 'undef'.

#### `config_file_template`

Determines the content of a configuration file. Defaults to 'undef'.

#### `config_file_require`

Determines which package a configuration file depends on. Defaults to 'undef'.

#### `config_file_hash`

Determines which configuration files should be managed via `hosts::define`.
Defaults to '{}'.

#### `config_file_options_hash`

Determines which parameters should be passed to an ERB template. Defaults to '{}'.

## Limitations

This module has been tested on:

* Debian 6/7/8
* Ubuntu 12.04/14.04/16.04

## Development

### Bug Report

If you find a bug, have trouble following the documentation or have a question
about this module - please create an issue.

### Pull Request

If you are able to patch the bug or add the feature yourself - please make a
pull request.

### Contributors

The list of contributors can be found at: [https://github.com/dhoppe/puppet-hosts/graphs/contributors](https://github.com/dhoppe/puppet-hosts/graphs/contributors)
