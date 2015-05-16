# == Define: tftpboot:generic_model
#
# This is for generic entries
#
# == Parameters
#
# [*name*]
#   Should describe the purpose of the file.
#
# [*content*]
#   The actual verbatim content of the entry.
#
# [*ensure*]
#   'absent' or 'present'
#   Defaults to 'present'
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define tftpboot::generic_model (
  $content,
  $ensure = 'present'
) {
    file { "/tftpboot/pxe-linux/templates/${name}":
        ensure  => $ensure,
        owner   => 'root',
        group   => 'nobody',
        mode    => '0640',
        content => $content
    }

    validate_string($content)
    validate_re($ensure, '^(absent|present)$')
}
