# define tftpboot:generic_model
#
# This define is for generic entries used to PXEboot a server.
# The generic entries will be written to
# `$::tftpboot::tftpboot_root_dir/pxe-linux/templates`.
#
# == Parameters
#
# @attr name Should describe the purpose of the file.
#
# @param content The actual verbatim content of the entry.
#
# @param ensure Ensure for files managed.
#
define tftpboot::generic_model (
  String                   $content,
  Enum['absent','present'] $ensure = 'present'
) {

  if ! ($name =~ /^\S+$/) {
    fail("tftpboot::generic_model '${name}' invalid: name cannot have whitespace")
  }

  include 'tftpboot'

  $install_dir = "${::tftpboot::tftpboot_root_dir}/pxe-linux/templates"
  file { "${install_dir}/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    seltype => 'tftpdir_t',
    content => $content
  }
}
