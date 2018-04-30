# define tftpboot:assign_host
#
#  Sets up links to `templates/$model` in the `tftpboot.cfg/`
#  sub-directory of `$::tftpboot::install_root_dir`
#
# @attr name  Should be the PXE boot identifier per the PXE
#   documentation or 'default', the appropriate default filename for
#   BIOS boot. This identifier will map directly to a single file named
#   downcase($name) or a pair of files named downcase($name) and
#   upcase($name), all in `tftpboot.cfg/`. These filenames support
#   the configuration file search shown below:
#     (1) UUID
#     (2) 01-MAC (for Ethernet)
#     (3) Descending IP address ranges in HEX.
#         For example:
#         C000025B
#         C000025
#         ...
#         C
#     (4) The file 'default'
#
# @param model Should be the name of a previously defined model
#
# @param ensure Ensure for files managed.
#
define tftpboot::assign_host (
  String                $model,
  Enum['absent','link'] $ensure = 'link'
) {

  include 'tftpboot'

  if ! ($name =~ /^\S+$/) {
    fail("tftpboot::assign_host '${name}' invalid: name cannot have whitespace")
  }

  $_install_dir = "${::tftpboot::install_root_dir}/pxelinux.cfg"

  if $name == 'default' {
    file { "${_install_dir}/default":
      ensure  => $ensure,
      owner   => 'root',
      group   => 'nobody',
      mode    => '0644',
      seltype => 'tftpdir_t',
      target  => "templates/${model}",
      force   => true
    }
  } else {
    $_upname = upcase($name)
    $_downname = downcase($name)

    file { "${_install_dir}/${_downname}":
      ensure  => $ensure,
      owner   => 'root',
      group   => 'nobody',
      mode    => '0644',
      seltype => 'tftpdir_t',
      target  => "templates/${model}",
      force   => true
    }

    # normal comparison operators (==, !=, =~, etc.) are case invariant
    # in Puppet, so have to compare via a different method
    if !member([$_downname], $_upname) {
      file { "${_install_dir}/${_upname}":
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
