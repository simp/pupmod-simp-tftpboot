[![License](http://img.shields.io/:license-apache-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0.html)
[![CII Best Practices](https://bestpractices.coreinfrastructure.org/projects/73/badge)](https://bestpractices.coreinfrastructure.org/projects/73)
[![Puppet Forge](https://img.shields.io/puppetforge/v/simp/tftpboot.svg)](https://forge.puppetlabs.com/simp/tftpboot)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/simp/tftpboot.svg)](https://forge.puppetlabs.com/simp/tftpboot)
[![Build Status](https://travis-ci.org/simp/pupmod-simp-tftpboot.svg)](https://travis-ci.org/simp/pupmod-simp-tftpboot)

# pupmod-simp-tftpboot

#### Table of Contents

<!-- vim-markdown-toc GFM -->

* [Description](#description)
* [Setup](#setup)
  * [What tftpboot affects](#what-tftpboot-affects)
* [Usage](#usage)
  * [Kernel arguments](#kernel-arguments)
* [Breaking changes in 9.0.0](#breaking-changes-in-900)
* [Limitations](#limitations)
* [Development](#development)

<!-- vim-markdown-toc -->

## Description

Sets up a tftpboot server.

See [REFERENCE.md](./REFERENCE.md) for the full API reference.

## Setup

Install `simp/tftpboot` to your module path. A SIMP rsync server must also be in
place to use the tftpboot module.

### What tftpboot affects

Manages the following:

* `tftp-server` package
* `tftp.socket` service
* `/var/lib/tftpboot/linux-install` directory and its contents

## Usage

    include tftpboot

See the [SIMP Documentation](https://simp.readthedocs.io/en/master/search.html?q=tftpboot&check_keywords=yes&area=default)
for detailed examples of using this module.

### Kernel arguments

The PXE entries boot the installer with `inst.ks=<ks> fips=<0|1> <extra>`.
The `inst.` prefix is mandatory on EL9 and EL10.

`fips` defaults to `simp_options::fips`; the EL8/9/10 SIMP kickstarts install
the host in FIPS mode only when it is `1`. `fips=1` *may not work* with all
initrd images: one built without dracut's `fips` module can fail to boot with
it, so set `fips => false` on such a model.

Options you add through `extra` need the `inst.` prefix too (`inst.repo=`,
`inst.stage2=`); the models log a warning when they find an un-prefixed
installer option. On a host with several NICs, pin the installer to the right
interface:

* BIOS (`tftpboot::linux_model`): add pxelinux's `IPAPPEND 2` on its own line,
  for example `extra => "ip=dhcp\nIPAPPEND 2"`. pxelinux then appends
  `BOOTIF=<MAC>`, and the installer uses the interface it PXE booted from.
* UEFI (`tftpboot::linux_model_efi`): grub2 has no `IPAPPEND`, so name the
  interface with `ip=<iface>:dhcp` or `bootdev=<iface> ip=dhcp`.

## Breaking changes in 9.0.0

* The kickstart location is passed as `inst.ks=` instead of `ks=`.
* The `legacy_grub` parameter of `tftpboot::linux_model_efi` and
  `tftpboot::assign_host_efi` is removed, with its template. Legacy grub EFI
  only booted EL6-era installers.
* `fips` defaults to `simp_options::fips` instead of `false`. Set
  `fips => false` on a model to keep the old behavior.

## Limitations

SIMP Puppet modules are generally intended for use on Red Hat Enterprise
Linux and compatible distributions, such as CentOS. Please see the
[`metadata.json` file](./metadata.json) for the most up-to-date list of
supported operating systems, Puppet versions, and module dependencies.

## Development

Please read our [Contribution Guide](https://simp.readthedocs.io/en/stable/contributors_guide/index.html).

If you find any issues, they can be submitted to our
[JIRA](https://simp-project.atlassian.net).
