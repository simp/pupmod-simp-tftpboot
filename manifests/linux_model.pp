#
# Add a TFTPBoot Linux model entry
#
# @attr name [String] Describes the purpose of the file
#
# @param kernel The location of the kernel within the tftpboot tree.
#               Should *not* be an absolute path.
#
# @param initrd The location of the kernel within the tftpboot tree.
#               Should *not* be an absolute path.
#
# @param ks The full URL to the location of the kickstart file.
#
# @param extra Any other kernel parameters that you would like to pass at boot.
#              You will probably want this to be
#              'ksdevice=bootif\nIPAPPEND 2' if you are kickstarting
#              systems.
#
# @param ensure Set, or delete, this entry.  Options: ['absent'|'present']
#
# @param fips If true, enables FIPS in the kernel parameters at PXE
#             time. This *may not work* with all initrd images.
#
define tftpboot::linux_model (
  String $kernel,
  String $initrd,
  String $ks,
  Optional[String] $extra          = undef,
  Enum['absent','present'] $ensure = 'present',
  Boolean $fips                    = false
){
  file { "/tftpboot/linux-install/pxelinux.cfg/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template('tftpboot/entry.erb'),
    mode    => '0644'
  }
}
