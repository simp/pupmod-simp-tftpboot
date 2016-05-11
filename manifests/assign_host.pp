# == Define: tftpboot:assign_host
#
#  Sets up links to /tftpboot/linux-install/pxelinux.cfg/templates/$model
#
# == Parameters
#
# [*name*]
#   Should be the PXE boot identifier per the PXE documentation.
#   Search order:
#     - First UUID
#     - Then 01-MAC (for Ethernet)
#     - Last descending IP address ranges in HEX
#     - Finally, the file 'default'
#
# [*model*]
#   Should be the name of a previously defined model
#
# [*ensure*]
#   'absent' or 'present'.
#   Defaults to: 'present'
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define tftpboot::assign_host (
  $model,
  $ensure = 'present'
) {
  validate_string($model)
  validate_re($ensure,'^(absent|present|file|link)$')

  $_upname = inline_template('<%= @name.upcase %>')
  $_downname = inline_template('<%= @name.downcase %>')
  $_ensure = $ensure ? {
    'present' => 'link',
    'file'    => 'link',
    'link'    => 'link',
    default   => 'absent'
  }

  file { "/tftpboot/linux-install/pxelinux.cfg/${_downname}":
    ensure => $_ensure,
    owner  => 'root',
    group  => 'nobody',
    mode   => '0644',
    target => "templates/${model}",
    force  => true
  }

  $_downname_parts = split($_downname,' ')
  if ( $_downname != 'default' ) and ( ! ( $_upname in $_downname_parts ) ) {
    file { "/tftpboot/linux-install/pxelinux.cfg/${_upname}":
      ensure => $_ensure,
      owner  => 'root',
      group  => 'nobody',
      mode   => '0644',
      target => "templates/${model}",
      force  => true
    }
  }
}
