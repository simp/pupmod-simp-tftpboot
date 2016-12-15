# define tftpboot:generic_model
#
# This is for generic entries
#
# == Parameters
#
# @attr name Should describe the purpose of the file.
#
# @param content The actual verbatim content of the entry.
#
# @param ensure Ensure for files managed.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
define tftpboot::generic_model (
  String $content,
  Enum['absent','present'] $ensure = 'present'
) {

  file { "/tftpboot/pxe-linux/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    content => $content
  }
}
