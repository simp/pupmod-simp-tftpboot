# == Define: tftpboot::linux_model
#
# This is for Linux entries
#
# == Parameters
#
# [*name*]
#   Should describe the purpose of the file.
#
# [*kernel*]
#   The location of the kernel within the tftpboot tree.
#
# [*initrd*]
#   The location of the initrd within the tftpboot tree.
#
# [*ks*]
#   The URL of where to obtain the kickstart file.
#
# [*extra*]
#   Can contain any other kernel strings that you would like to pass.
#   You probably want 'ksdevice=bootif\nIPAPPEND 2' if you're kickstarting systems
#
# [*ensure*]
#   Can be set to 'absent' or 'present'.
#   Defaults to present.
#
# [*fips*]
#   Boolean.  If true, enables FIPS in the grub configuration.
#   Defaults to false.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
define tftpboot::linux_model (
  $kernel,
  $initrd,
  $ks,
  $extra = 'nil',
  $ensure = 'present',
  $fips = hiera('use_fips', false)
){
  file { "/tftpboot/linux-install/pxelinux.cfg/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template('tftpboot/entry.erb'),
    mode    => '0644'
  }

  validate_string($kernel)
  validate_string($initrd)
  validate_string($ks)
  if $extra != 'nil' { validate_string($extra) }
  validate_re($ensure, '^(absent|present)$')
  validate_bool($fips)
}
