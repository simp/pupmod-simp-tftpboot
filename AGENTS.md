# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## What this module does

`simp-tftpboot` is a SIMP Puppet module that stands up a **PXE / TFTP
network-boot environment** on Enterprise Linux. It installs the `tftp-server`
package, enables the `tftp.socket` systemd unit (`manifests/init.pp:74-82`),
lays out the TFTP root directory tree, and populates it with the initial boot
files needed to PXEboot other machines. It supports **both** boot paths that a
modern PXE environment must serve:

- **Legacy BIOS PXE boot** via `pxelinux`/`syslinux` — configuration lives under
  `<install_root>/pxelinux.cfg` (`manifests/config/bios.pp`).
- **UEFI boot** via grub (both grub2 and legacy grub) — configuration lives
  under `<install_root>/efi` (`manifests/config/efi.pp`).

The initial boot files (kernels, `pxelinux.0`, `menu.c32`, `grubx64.efi`,
`shimx64.efi`, etc.) come from one of two sources, selected by
`$use_os_files`/`$rsync_enabled`:

- **From OS packages** (`$use_os_files = true`, the default): the config classes
  install the OS packages named in `$os_file_info` and copy each listed file
  into the TFTP tree (`config/bios.pp:32-57`, `config/efi.pp:25-50`).
- **From a central rsync server** (`$rsync_enabled = true`, the default): the
  entire PXEboot hierarchy is pulled from an rsync server into
  `$tftpboot_root_dir` (`config.pp:36-48`). This is why `simp/rsync` is a **hard
  runtime dependency**, not optional.

On top of the environment, the module's defined types let you describe *what to
boot* and *who boots it*:

- **`tftpboot::linux_model`** / **`tftpboot::linux_model_efi`** — write a
  per-model Linux boot entry (a template file naming a kernel, initrd, kickstart
  URL, and extra kernel args) for BIOS and UEFI respectively.
- **`tftpboot::generic_model`** — write a verbatim boot entry with
  caller-supplied content.
- **`tftpboot::assign_host`** / **`tftpboot::assign_host_efi`** — bind a host
  (by PXE identifier, typically `01-MAC`, or `default`) to a previously defined
  model by creating symlinks to that model's template.

### Business logic

- **`tftpboot` (`manifests/init.pp:57-83`)** — public entry class; consumers
  `include 'tftpboot'`. It is **not** `assert_private()`'d.
  - `$os_file_info` (`Hash`, **no default**) — required; supplied from module
    data (`data/os/*.yaml`). Maps `'bios'`/`'efi'` → OS package → list of files
    that package provides (`init.pp:45-51`, `data/os/RedHat.yaml`).
  - `$tftpboot_root_dir` (`Stdlib::Absolutepath`, default `/var/lib/tftpboot`)
    and `$linux_install_dir` (`String`, default `linux-install`) combine into
    `$install_root_dir = "${tftpboot_root_dir}/${linux_install_dir}"`
    (`init.pp:70`) — the path most of the module hangs off of.
  - `$rsync_source` defaults to
    `"tftpboot_${environment}_${facts['os']['name']}/*"` (`init.pp:63`).
  - Installs `Package['tftp-server']` at `$package_ensure`, orders it before
    `Class['tftpboot::config']`, and runs `service { 'tftp.socket' }`
    (`init.pp:74-82`).
- **`tftpboot::config` (`manifests/config.pp`)** — private (`assert_private()`,
  `config.pp:6`). `contain`s `tftpboot::config::bios` and
  `tftpboot::config::efi` (`config.pp:8-9`), creates the root and install
  directories, and — when `$rsync_enabled` — `include`s `rsync` and declares the
  `rsync { 'tftpboot' }` pull (`config.pp:36-48`). When `$use_os_files`, it
  excludes the OS-provided base filenames (via
  `tftpboot::get_os_base_filenames`) plus `pxelinux.cfg` from the rsync so the
  OS-package copies win (`config.pp:27-32`).
- **`tftpboot::config::bios` (`manifests/config/bios.pp`)** — private
  (`assert_private()`, `bios.pp:6`). Manages `pxelinux.cfg/` (purged per
  `$purge_configs`, `recurselimit => 1`) and `pxelinux.cfg/templates/`, and when
  `$use_os_files` installs the `bios` OS packages and copies their files into the
  install dir via `file { ...: source => "file://${file}" }`.
- **`tftpboot::config::efi` (`manifests/config/efi.pp`)** — private
  (`assert_private()`, `efi.pp:6`). Same pattern as bios but under `efi/` and
  using the `efi` half of `$os_file_info`.
- **`tftpboot::get_os_base_filenames` (`functions/get_os_base_filenames.pp`)** —
  Puppet-language function. Takes the `$os_file_info` Hash and returns a flat
  `Array` of `basename()`s of every file (across both `bios` and `efi`). Used to
  build the rsync exclude list so rsync does not overwrite the OS-package files.

Defined types (all `include 'tftpboot'` and reject whitespace in `$name`):

- **`tftpboot::linux_model` (`manifests/linux_model.pp:24-47`)** — params
  `$kernel`, `$initrd`, `$ks` (required), `$extra`, `$ensure`
  (`present`/`absent`), `$fips`. Writes
  `<install_root>/pxelinux.cfg/templates/${name}` from
  `template('tftpboot/entry.erb')`.
- **`tftpboot::linux_model_efi` (`manifests/linux_model_efi.pp:26-67`)** — same
  params plus `$legacy_grub`. Picks `entry_efi_legacy_grub.erb` (with `/../`
  relative kernel/initrd paths, `linux_model_efi.pp:41-50`) or `entry_efi.erb`
  (with `/${linux_install_dir}/` paths, `:51-55`) and writes
  `<install_root>/efi/templates/${name}`.
- **`tftpboot::generic_model` (`manifests/generic_model.pp:15-34`)** — params
  `$content` (verbatim), `$ensure`. Writes
  `<tftpboot_root>/pxe-linux/templates/${name}`. Note the different subdirectory
  (`pxe-linux`, not the `$linux_install_dir` tree).
- **`tftpboot::assign_host` (`manifests/assign_host.pp:26-76`)** — params
  `$model` (required), `$ensure` (`link`/`absent`, default `link`). For
  `$name == 'default'` symlinks `pxelinux.cfg/default` → `templates/${model}`;
  otherwise symlinks both the downcased and (if different) upcased `$name`,
  because the PXE filename search is case-sensitive.
- **`tftpboot::assign_host_efi` (`manifests/assign_host_efi.pp:51-151`)** —
  params `$model` (required), `$legacy_grub` (default `false`), `$ensure`. Maps
  `default`/`efidefault`/`grub.cfg` to the right default filename; otherwise
  prefixes non-default names with `grub.cfg-` (grub2) or nothing (legacy grub),
  symlinking down/up-cased variants. Includes a **RedHat 7.4 grub2 workaround**
  that also creates trailing-`-` filenames for `01-MAC` names
  (`assign_host_efi.pp:107-121,136-148`; see
  <https://bugzilla.redhat.com/show_bug.cgi?id=1487107>).

## Gotchas / non-obvious details

- **`simp/rsync` is a hard dependency, not optional.** By default the module
  pulls the entire PXEboot hierarchy from an rsync server
  (`$rsync_enabled = true`, `config.pp:36-48`). If you set `$rsync_enabled =
  false` you **must** supply the boot files into `$tftpboot_root_dir` by some
  other means (`init.pp:15-20`). There are no `optional_dependencies` in this
  module.
- **`$os_file_info` has no default** (`init.pp:58`); it is data-in-modules and
  must come from Hiera (`data/os/*.yaml`). Applying with an empty/absent value
  will fail compilation.
- **rsync exclude protects the OS-package files.** When both `$use_os_files` and
  `$rsync_enabled` are true, the OS-package copies and `pxelinux.cfg` are added
  to the rsync `exclude` list (`config.pp:27-32`) so the rsync pull does not
  clobber them — the OS files and the rsync content are meant to be
  complementary, not overlapping.
- **BIOS and UEFI live in parallel trees and have parallel defines.**
  `pxelinux.cfg/` (BIOS) vs `efi/` (UEFI). Anything you add for one boot path
  usually needs an `_efi` counterpart. Note the asymmetry called out in the
  code: **there is no purge mechanism for the `efi/` tree** — `$purge_configs`
  only purges `pxelinux.cfg/` (`init.pp:33-38`, `bios.pp:17`).
- **`assign_host*` symlinks both cases of the name on purpose.** Puppet's
  comparison operators are case-invariant, so the code compares via `member()`
  and creates both `downcase` and `upcase` files (`assign_host.pp:62-74`) —
  because the PXE/TFTP filename search itself *is* case-sensitive.
- **`assign_host_efi` carries a live grub2 bug workaround.** For `01-MAC` names
  under grub2 it deliberately creates an extra filename with a trailing `-`
  (RH 7.4 bug 1487107). Don't "clean this up" without understanding it.
- **`generic_model` writes to a different directory** (`pxe-linux/templates`,
  `generic_model.pp:25`) than the `linux_model*` defines (which use
  `$install_root_dir/{pxelinux.cfg,efi}/templates`). This looks inconsistent but
  is intentional per the docstring.
- **`entry*.erb` templates read define-local `@`-variables** (`@kernel`,
  `@initrd`, `@ks`, `@extra`, `@fips`, and for EFI `@_kernel`/`@_initrd`/`@name`)
  — they are rendered from within the defined types, so those instance variables
  come from the define's scope (`templates/entry.erb`, `entry_efi.erb`,
  `entry_efi_legacy_grub.erb`).
- **`simp/simp_options` is NOT a declared dependency** in `metadata.json`, yet
  `init.pp` consumes the `simp_options::*` seam via `simplib::lookup` (provided
  by `simp/simplib`). Keep routing feature toggles through that seam with an
  explicit `default_value` rather than assuming `simp_options` is included.

## The `simp_options` / `simplib::lookup` seam

All calls are in `manifests/init.pp`:

| Line | Key | `default_value` |
|------|-----|-----------------|
| `init.pp:61` | `simp_options::trusted_nets` | `['127.0.0.1', '::1']` |
| `init.pp:64` | `simp_options::rsync::server` | `'127.0.0.1'` |
| `init.pp:65` | `simp_options::rsync::timeout` | `2` |
| `init.pp:68` | `simp_options::package_ensure` | `'installed'` |

## Dependencies

Module dependencies (from `metadata.json`):

- `puppetlabs/stdlib` `>= 8.0.0 < 10.0.0` (provides `member()`, `keys()`,
  `basename()`, `flatten()`, etc.).
- `simp/rsync` `>= 6.1.1 < 8.0.0` — **hard runtime dependency**; provides the
  `rsync` class and `rsync` type used to pull boot files (`config.pp:37-47`).
- `simp/simplib` `>= 4.9.0 < 5.0.0` — provides `simplib::lookup`,
  `simplib::passgen` (`config.pp:41`), and the `Simplib::Netlist` type
  (`init.pp:61`).

There are **no** `optional_dependencies` and no `assert_optional_dependency`
calls in this module.

Runtime requirement (from `metadata.json` `requirements`): `puppet
>= 7.0.0 < 9.0.0`. (This module is still on the Puppet baseline, not yet on
OpenVox; when `metadata.json` switches this to `openvox`, update this line to
match.)

Supported OS matrix (from `metadata.json`): CentOS 9/10; RedHat 8/9/10;
OracleLinux 8/9; Rocky 8/9; AlmaLinux 8/9/10.

## Repository layout

- `manifests/init.pp` — public `tftpboot` class (server package, socket,
  `$install_root_dir`).
- `manifests/config.pp` — private orchestration class (`assert_private()`);
  directory tree + rsync pull.
- `manifests/config/bios.pp`, `manifests/config/efi.pp` — private config classes
  (`assert_private()`) for the BIOS and UEFI trees.
- `manifests/linux_model.pp`, `manifests/linux_model_efi.pp`,
  `manifests/generic_model.pp` — defined types that write boot entries.
- `manifests/assign_host.pp`, `manifests/assign_host_efi.pp` — defined types that
  symlink hosts to models.
- `functions/get_os_base_filenames.pp` — Puppet-language function returning the
  flat list of OS base filenames (used for the rsync exclude list).
- `templates/entry.erb` — BIOS pxelinux boot entry.
- `templates/entry_efi.erb` — UEFI grub2 boot entry.
- `templates/entry_efi_legacy_grub.erb` — UEFI legacy-grub boot entry.
- `data/os/*.yaml` (AlmaLinux, CentOS, OracleLinux, RedHat, Rocky) — supply
  `tftpboot::os_file_info` (the OS-package → boot-file map).
- `hiera.yaml` — module data hierarchy (v5): OS name+release → OS name → OS
  family → kernel → common.
- `metadata.json` — deps, OS matrix, Puppet requirement.
- `spec/` — rspec-puppet unit tests and the beaker acceptance suite.
- `REFERENCE.md` — generated Puppet Strings reference.
- No `types/` and no `lib/` — this module defines no custom Puppet 4.x data types
  and no Ruby types/providers/facts. Its only custom function is the
  Puppet-language `tftpboot::get_os_base_filenames`.

### CI (`.github/workflows/pr_tests.yml`)

Also **puppetsync**-managed (baseline-owned; see the notice at the top of the
file). Six standard jobs run on `ubuntu-latest`:

- `puppet-syntax` — `bundle exec rake syntax`
- `puppet-style` — `bundle exec rake lint` + `metadata_lint`
- `ruby-style` — `bundle exec rake rubocop` (`continue-on-error`)
- `file-checks` — `rake check:dot_underscore` + `check:test_file`
- `releng-checks` — version/tag/changelog checks + `pdk build --force`
- `spec-tests` — `bundle exec rake spec` across a Puppet 7.x / 8.x matrix

Plus an **active `acceptance` job** (`pr_tests.yml:130-162`). Unlike some SIMP
modules, this one runs on **podman/docker**, *not* `vagrant_libvirt`: it starts
the rootless podman socket and exports
`DOCKER_HOST=unix:///run/user/<uid>/podman/podman.sock`
(`pr_tests.yml:156-159`), then runs
`bundle exec rake beaker:suites[default,<node>]` (`:160-162`). The matrix has 9
nodes: `docker_alma8`, `docker_alma9`, `docker_alma10`, `docker_centos9`,
`docker_centos10`, `docker_oel8`, `docker_oel9`, `docker_rocky8`,
`docker_rocky9` (`:135-144`). `spec/acceptance/nodesets/` ships 14 nodeset files
(the `docker_*` set including `docker_rhel8/9/10.yml`, plus `default.yml` and
`oel.yml`); there is 1 acceptance suite,
`spec/acceptance/suites/default/00_default_spec.rb`.

## Common commands

```sh
# Install dependencies
bundle install

# Run all unit tests
bundle exec rake spec

# Puppet lint
bundle exec rake lint

# Ruby lint
bundle exec rake rubocop

# Regenerate REFERENCE.md from puppet-strings docstrings
puppet strings generate --format markdown --out REFERENCE.md

# Run the default beaker acceptance suite against a docker/podman node
bundle exec rake beaker:suites[default,docker_alma9]
```

Relevant gem pins (from `Gemfile`): `puppetlabs_spec_helper ~> 8.0.0`
(`Gemfile:30`), `simp-rake-helpers ~> 5.24.0` (`Gemfile:36`),
`simp-beaker-helpers ~> 2.0.0` (`Gemfile:53`); `rubocop` is pinned to
`~> 1.88.0` (`Gemfile:16`). The Puppet gem is installed only via
`gem 'puppet', puppet_version` (`Gemfile:29`) where `puppet_version` defaults to
`['>= 7', '< 9']` (`Gemfile:23`). `spec/spec_helper.rb:11` requires
`puppetlabs_spec_helper/module_spec_helper`.

## Conventions

- Preserve the `@summary` / `@param` / `@attr` puppet-strings docstrings on every
  class and defined type — they drive `REFERENCE.md`. Regenerate `REFERENCE.md`
  after changing docs or parameters.
- Keep `tftpboot::os_file_info` in module data (`data/os/*.yaml`), not hard-coded
  in a manifest.
- Keep the config classes private (`assert_private()`) and mirror any BIOS change
  with its UEFI counterpart (and vice versa).
- Route SIMP feature toggles through
  `simplib::lookup('simp_options::*', { 'default_value' => ... })` with an
  explicit default rather than assuming `simp_options` is included.
- Guard against whitespace in `$name` in defined types, as the existing defines
  do (`fail(...)` on `! ($name =~ /^\S+$/)`).
- `Gemfile`, `spec/spec_helper.rb`, and `.github/workflows/pr_tests.yml` carry a
  **puppetsync** notice — they are baseline-managed and the next sync overwrites
  local edits. Push changes to those files upstream to the baseline, not here.
- Match the existing 2-space Puppet indentation and aligned-arrow parameter
  style used throughout `manifests/`.
