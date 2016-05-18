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
# [*set_fips_initrd*]
#   Boolean.  If true, enables [*fips*] logic in the initrd configuration, otherwise
#   fips is omitted.  WARNING: setting this to true while using the stock EL7
#   initrd image will cause kickstart to fail if SSL is utilized (https by default).
#   Defaults to false.
#
# [*fips*]
#   Boolean.  If true, enables FIPS in the grub and initrd configuration.
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
  $set_fips_initrd = false,
  $fips = hiera('use_fips', false),
){
  validate_string($kernel)
  validate_string($initrd)
  validate_string($ks)
  if $extra != 'nil' { validate_string($extra) }
  validate_re($ensure, '^(absent|present)$')
  validate_bool($fips)
  validate_bool($set_fips_initrd)

  file { "/tftpboot/linux-install/pxelinux.cfg/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template('tftpboot/entry.erb'),
    mode    => '0644'
  }
}
