#
# Add a TFTPBoot Linux model entry
#
# @param name [String] Describes the purpose of the file
# @param kernel [String] The location of the kernel within the tftpboot tree.
#                        Should *not* be an absolute path.
# @param initrd [String] The location of the kernel within the tftpboot tree.
#                        Should *not* be an absolute path.
# @param ks [String] The full URL to the location of the kickstart file.
# @param extra [String] Any other kernel parameters that you would like to pass at boot.
#                       You will probably want this to be
#                       'ksdevice=bootif\nIPAPPEND 2' if you are kickstarting
#                       sytems.
# @param ensure [String] Set, or delete, this entry.
#                        Options: ['absent'|'present']
# @param fips [Boolean] If true, enables FIPS in the kernel parameters at PXE
#                       time. This *may not work* with all initrd images.
#
define tftpboot::linux_model (
  $kernel,
  $initrd,
  $ks,
  $extra = 'nil',
  $ensure = 'present',
  $fips = false
){
  validate_string($kernel)
  validate_string($initrd)
  validate_string($ks)
  if $extra != 'nil' { validate_string($extra) }
  validate_re($ensure, '^(absent|present)$')
  validate_bool($fips)

  file { "/tftpboot/linux-install/pxelinux.cfg/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template('tftpboot/entry.erb'),
    mode    => '0644'
  }
}
