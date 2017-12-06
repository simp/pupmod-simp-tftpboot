[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/tftpboot.svg)](https://forge.puppetlabs.com/simp/tftpboot)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/tftpboot.svg)](https://forge.puppetlabs.com/simp/tftpboot)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-tftpboot.svg)](https://travis-ci.org/simp/pupmod-simp-tftpboot)

# pupmod-simp-tftpboot

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with tftpboot](#setup)
    * [What tftpboot affects](#what-tftpboot-affects)
    * [Setup requirements](#setup-requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Reference](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Description

Sets up a tftpboot server.

## Setup

Install `simp/tftpboot` to your modulepath. A SIMP rsync server must also be in
place to use the tftpboot module.

### What tftpboot affects

Manages the following:

* `tftp-server` package
* `tftp` service (via `xinetd`)
* `/tftpboot/` directory and its contents

### Setup Requirements

This module requires the following:

* [puppetlabs-stdlib](https://forge.puppet.com/puppetlabs/stdlib)
* [simp-rsync](https://forge.puppet.com/simp/rsync)
* [simp-simplib](https://forge.puppet.com/simp/simplib)
* [simp-xinetd](https://forge.puppet.com/simp/xinetd)

## Usage

    class { 'tftpboot': }

## Reference

### Public Classes

* [tftpboot](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/init.pp)

#### Parameters

* **`trusted\_nets`** (`Array[String]`) *(defaults to: `simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'] })`)*

See only\_from in xinetd.conf(5). This will be converted to DDQ format automatically.

* **`rsync\_source`** (`String`) *(defaults to: `"tftpboot_${::environment}_${facts['os']['name']}/*"`)*

The source of the content to be rsync'd.

* **`rsync\_server`** (`String`) *(defaults to: `simplib::lookup('simp_options::rsync::server',  { 'default_value' => '127.0.0.1' })`)*

The rsync server FQDN from which to pull the tftpboot configuration. This should contain the entire PXEboot hierarchy if you wish to use this to PXEboot servers.

* **`rsync\_timeout`** (`Integer`) *(defaults to: `simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2 })`)*

The connection timeout for the rsync connections.

* **`purge\_configs`** (`Boolean`) *(defaults to: `true`)*

Determines if non puppet-managed configuration files in /tftpboot/linux-install/pxelinux.cfg get purged.

* **`use\_os\_files`** (`Boolean`) *(defaults to: `true`)*

If true, use the OS provided syslinux packages to obtain the pxelinux.0 file.

### Defined Types

* [tftpboot::assign_host](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/assign_host.pp): Sets up links to `/tftpboot/linux-install/pxelinux.cfg/templates/$model`

#### Parameters

* **`model`** (`String`)

Should be the name of a previously defined model

* **`ensure`** (`Enum['absent','present','file','link']`) *(defaults to: `'present'`)*

Ensure for files managed.

---

* [tftpboot::generic_model](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/generic_model.pp): This is for generic entries

#### Parameters

* **`content`** (`String`)

The actual verbatim content of the entry.

* **`ensure`** (`Enum['absent','present']`) *(defaults to: `'present'`)*

Ensure for files managed.

---

* [tftpboot::linux_model](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/linux_model.pp): Add a TFTPBoot Linux model entry

#### Parameters

* **`kernel`** (`String`)

The location of the kernel within the tftpboot tree. Should *not* be an absolute path.

* **`initrd`** (`String`)

The location of the kernel within the tftpboot tree. Should *not* be an absolute path.

* **`ks`** (`String`)

The full URL to the location of the kickstart file.

* **`extra`** (`Optional[String]`) *(defaults to: `undef`)*

Any other kernel parameters that you would like to pass at boot. You will probably want this to be 'ksdevice=bootifnIPAPPEND 2' if you are kickstarting systems.

* **`ensure`** (`Enum['absent','present']`) *(defaults to: `'present'`)*

Set, or delete, this entry. Options: \['absent'|'present'\]

* **`fips`** (`Boolean`) *(defaults to: `false`)*

If true, enables FIPS in the kernel parameters at PXE time. This *may not work* with all initrd images.

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise
Linux and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).
