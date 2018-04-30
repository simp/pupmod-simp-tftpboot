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
* `/var/lib/tftpboot/linux-install` directory and its contents

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

* [tftpboot](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/init.pp) Sets up a tftpboot server

#### Parameters

* **`tftpboot_root_dir`** (`Stdlib::Absolutepath`) *(defaults to: `/var/lib/tftpboot`)*

The root directory of tftboot.

* **`linux_install_dir`** (`String`) *(defaults to: `linux-install`)*

The name of a sub-directory of `$tftpboot_root_dir` (relative path) that contains files
used to PXEboot a server.

* **`trusted_nets`** (`Array[String]`) *(defaults to: `simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'] })`)*

See only\_from in xinetd.conf(5). This will be converted to DDQ format automatically.

* **`rsync_enabled`** (`Boolean`) *(defaults to: `true`)*

Whether to use rsync to efficiently pull initial boot files from a
central location (i.e., the rsync server) and install them into
`$tftpboot_root_dir/$linux_install_dir`.  When set to `false`, you
must provide some other mechanism to install the initial boot files
into `$tftpboot_root_dir/$linux_install_dir`.

* **`rsync_source`** (`String`) *(defaults to: `"tftpboot_${::environment}_${facts['os']['name']}/*"`)*

The source of the content to be rsync'd.

* **`rsync_server`** (`String`) *(defaults to: `simplib::lookup('simp_options::rsync::server',  { 'default_value' => '127.0.0.1' })`)*

The rsync server FQDN from which to pull the tftpboot configuration. This should contain the entire PXEboot hierarchy if you wish to use this to PXEboot servers.

* **`rsync_timeout`** (`Integer`) *(defaults to: `simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2 })`)*

The connection timeout for the rsync connections.

* **`purge_configs`** (`Boolean`) *(defaults to: `true`)*

Determines if non puppet-managed configuration files in `$tftpboot_root_dir/$linux_install_dir/pxelinux.cfg`
get purged.  At this time, there is no purge mechanism for `$tftpboot_root_dir/$linux_install_dir/efi`,
which contains both configuration and initial boot files.

* **`use_os_files`** (`Boolean`) *(defaults to: `true`)*

If `true`, use the OS provided syslinux and grub packages to obtain the initial boot files
(e.g., `pxelinux.0`, `menu.c32`, `grub.efi`, `grubx64.efi`, `shim.efi`).

* **`use_file_info`** (`Hash`) *(defaults to data-in-module appropriate for OS)*

Hash of Hashes containing the mapping of OS packages to initial boot files.
The outer Hash key is either 'bios' or 'efi', corresponding to BIOS or UEFI boot,
respectively.  The inner Hash is a Hash of Arrays. Each inner Hash key is an
OS package.  Each inner Hash value is the list of PXEboot files
provided by the named package.  See the module data for specifics.

* **`package_ensure`** (`String`) The ensure status of packages to be installed.


### Defined Types

* [tftpboot::assign_host](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/assign_host.pp): Sets up links to
  `templates/$model` in the `tftpboot.cfg/` sub-directory of `$tftpboot::install_root_dir``

#### Parameters

* **`model`** (`String`)

Should be the name of a previously defined model

* **`ensure`** (`Enum['absent', 'link']`) *(defaults to: `'link'`)*

Ensure for files managed.

---
* [tftpboot::assign_host_efi](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/assign_host_efi.pp): Sets up links to
  `templates/$model` in the `efi/` sub-directory of `$tftpboot::install_root_dir``

#### Parameters

* **`legacy_grub`** (`Boolean`) *(defaults to : `false`)*

Whether this host uses legacy grub.

* **`model`** (`String`)

Should be the name of a previously defined model

* **`ensure`** (`Enum['absent', 'link']`) *(defaults to: `'link'`)*

Ensure for files managed.

---

* [tftpboot::generic_model](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/generic_model.pp):
  This is for generic entries used to PXEboot a server.  The generic entries will be written to
  `$::tftpboot::tftpboot_root_dir/pxe-linux/templates`.

#### Parameters

* **`content`** (`String`)

The actual verbatim content of the entry.

* **`ensure`** (`Enum['absent','present']`) *(defaults to: `'present'`)*

Ensure for files managed.

---

* [tftpboot::linux_model](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/linux_model.pp):
  Add a TFTPBoot Linux model entry for BIOS boot

#### Parameters

* **`kernel`** (`String`)

The location of the kernel within the tftpboot tree.
Path is relative to `$::tftpboot::install_root_dir`.

* **`initrd`** (`String`)

The location of the inital RAM disk within the tftpboot tree.
Path is relative to `$::tftpboot::install_root_dir`.

* **`ks`** (`String`)

The full URL to the location of the kickstart file.

* **`extra`** (`Optional[String]`) *(defaults to: `undef`)*

Any other kernel parameters that you would like to pass at boot. You will probably want this to be 'ksdevice=bootif\nIPAPPEND 2' if you are kickstarting systems.

* **`ensure`** (`Enum['absent','present']`) *(defaults to: `'present'`)*

Set, or delete, this entry. Options: \['absent'|'present'\]

* **`fips`** (`Boolean`) *(defaults to: `false`)*

If true, enables FIPS in the kernel parameters at PXE time. This *may not work* with all initrd images.

---

* [tftpboot::linux_model_efi](https://github.com/simp/pupmod-simp-tftpboot/blob/master/manifests/linux_model_efi.pp):
  Add a TFTPBoot Linux model entry for UEFI boot

#### Parameters

* **`kernel`** (`String`)

The location of the kernel within the tftpboot tree.
Path is relative to `$::tftpboot::install_root_dir`.

* **`initrd`** (`String`)

The location of the inital RAM disk within the tftpboot tree.
Path is relative to `$::tftpboot::install_root_dir`.

* **`ks`** (`String`)

The full URL to the location of the kickstart file.

* **`extra`** (`Optional[String]`) *(defaults to: `undef`)*

Any other kernel parameters that you would like to pass at boot. You will probably want this to be 'ksdevice=bootif\nIPAPPEND 2' if you are kickstarting systems.

* **`ensure`** (`Enum['absent','present']`) *(defaults to: `'present'`)*

Set or delete this entry. Options: \['absent'|'present'\]

* **`fips`** (`Boolean`) *(defaults to: `false`)*

If true, enables FIPS in the kernel parameters at PXE time. This *may not work* with all initrd images.

* **`legacy_grub`** (`Boolean`) *(defaults to : `false`)*

Whether this host uses legacy grub.

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise
Linux and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](http://simp-doc.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).
