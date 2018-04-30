# define tftpboot:assign_host_efi
#
#  Sets up links to `templates/$model` in the `efi/`
#  sub-directory of `$::tftpboot::install_root_dir`
#
# @attr name  Should be the PXE boot identifier per the PXE
#   documentation or the appropriate default filename ('efidefault'
#   for UEFI boot legacy grub, 'grub.cfg' for UEFI boot grub2). If
#   set to 'default' this define will determine the correct default
#   name based on its configuration parameters.
#
#   * For UEFI boot for legacy grub, when set to 'efidefault' or
#     'default', this configuration will map to a file
#     named 'efidefault' in `efi/`.  Otherwise, it will map to a
#     single file named downcase($name) or a pair of files named
#     downcase($name) and upcase($name), all in `efi/`.  These
#     filenames support the configuration file search shown below:
#     (1) UUID
#     (2) 01-MAC (for Ethernet)
#     (3) Descending IP address ranges in HEX.
#         For example:
#         C000025B
#         C000025
#         ...
#         C
#     (4) The file 'efidefault'
#
#   * For UEFI boot otherwise (grub2), when set to 'grub.cfg' or
#     'default', this configuration will map to a file named
#     'grub.cfg' in `efi/`.  Otherwise, it will nominally map to a
#     single file named "grub.cfg-<downcase($name)>" or a pair of
#     files named  "grub.cfg-<downcase($name)>" and
#     "grub.cfg-<upcase($name)>", all in `efi/`.  These filenames
#     support the configuration file search shown below:
#     (1) grub.cfg-UUID
#     (2) grub.cfg-01-MAC (for Ethernet)
#     (3) grub.cfg-<descending IP range in HEX>
#         For example:
#         grub.cfg-C000025B
#         grub.cfg-C000025
#         ...
#         grub.cfg-C
#     (4) grub.cfg
#
# @param legacy_grub Whether this host uses legacy grub.
#
# @param model Should be the name of a previously defined model
#
# @param ensure Ensure for files managed.
#
define tftpboot::assign_host_efi (
  String                $model,
  Boolean               $legacy_grub = false,
  Enum['absent','link'] $ensure      = 'link'
) {

  include 'tftpboot'

  if ! ($name =~ /^\S+$/) {
    fail("tftpboot::assign_host_efi '${name}' invalid: name cannot have whitespace")
  }

  $_install_dir = "${::tftpboot::install_root_dir}/efi"

  if $name == 'default' {
    $_default = true
    if $legacy_grub {
      $_default_filename = "${_install_dir}/efidefault"
    } else {
      $_default_filename = "${_install_dir}/grub.cfg"
    }
  } elsif member(['efidefault', 'grub.cfg'], $name) {
    $_default = true
    $_default_filename = "${_install_dir}/${name}"
  } else {
    $_default = false
  }

  if $_default {
    file { $_default_filename:
      ensure  => $ensure,
      owner   => 'root',
      group   => 'nobody',
      mode    => '0644',
      seltype => 'tftpdir_t',
      target  => "templates/${model}",
      force   => true
    }
  } else {
    if $legacy_grub {
      $_prefix = '' # lint:ignore:empty_string_assignment
    } else {
      $_prefix = 'grub.cfg-'
    }

    $_upname = upcase($name)
    $_downname = downcase($name)
    file { "${_install_dir}/${_prefix}${_downname}":
      ensure  => $ensure,
      owner   => 'root',
      group   => 'nobody',
      mode    => '0644',
      seltype => 'tftpdir_t',
      target  => "templates/${model}",
      force   => true
    }

    if ! $legacy_grub and $_downname =~ /^01\-/ {
      # WORKAROUND
      # RedHat 7.4 introduced a grub2 bug in which it erroneously adds
      # a '-' to the end of the MAC address-based grub config filename.
      # https://bugzilla.redhat.com/show_bug.cgi?id=1487107
      file { "${_install_dir}/${_prefix}${_downname}-":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'nobody',
        mode    => '0644',
        seltype => 'tftpdir_t',
        target  => "templates/${model}",
        force   => true
      }
    }

    # normal comparison operators (==, !=, =~, etc.) are case invariant
    # in Puppet, so have to compare via a different method
    if !member([$_downname], $_upname) {
      file { "${_install_dir}/${_prefix}${_upname}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'nobody',
        mode    => '0644',
        seltype => 'tftpdir_t',
        target  => "templates/${model}",
        force   => true
      }

      if ! $legacy_grub and $_downname =~ /^01\-/ {
        # WORKAROUND grub2 bug
        # https://bugzilla.redhat.com/show_bug.cgi?id=1487107
        file { "${_install_dir}/${_prefix}${_upname}-":
          ensure  => $ensure,
          owner   => 'root',
          group   => 'nobody',
          mode    => '0644',
          seltype => 'tftpdir_t',
          target  => "templates/${model}",
          force   => true
        }
      }
    }
  }
}
