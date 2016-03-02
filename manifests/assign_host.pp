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
  validate_re($ensure,'^(absent|present)$')

  $upname = inline_template('<%= @name.upcase %>')
  $downname = inline_template('<%= @name.downcase %>')
  $_ensure = $ensure ? {
    'present' => link,
    default   => 'absent'
  }

  file { "/tftpboot/linux-install/pxelinux.cfg/${downname}":
    ensure => $_ensure,
    owner  => 'root',
    group  => 'nobody',
    mode   => '0644',
    target => "templates/${model}",
    force  => true
  }

  $l_a_downname = split($downname,' ')
  if ( $downname != 'default' ) and ( ! ( $upname in $l_a_downname ) ) {
    file { "/tftpboot/linux-install/pxelinux.cfg/${upname}":
      ensure => $_ensure,
      owner  => 'root',
      group  => 'nobody',
      mode   => '0644',
      target => "templates/${model}",
      force  => true
    }
  }
}
