#
# Add a TFTPBoot Linux model entry for BIOS boot
#
# @attr name [String] Describes the purpose of the file
#
# @param kernel The location of the kernel within the tftpboot tree.
#               Path is relative to `$::tftpboot::install_root_dir`.
#
# @param initrd The location of the initial RAM disk within the tftpboot tree.
#               Path is relative to `$::tftpboot::install_root_dir`.
#
# @param ks The full URL to the location of the kickstart file.
#
# @param extra Any other kernel parameters that you would like to pass at boot.
#              You will probably want this to be
#              'ksdevice=bootif\nIPAPPEND 2' if you are kickstarting
#              systems.
#
# @param ensure Set or delete this entry.  Options: ['absent'|'present']
#
# @param fips If true, enables FIPS in the kernel parameters at PXE
#             time. This *may not work* with all initrd images.
#
define tftpboot::linux_model (
  String                   $kernel,
  String                   $initrd,
  String                   $ks,
  Optional[String]         $extra  = undef,
  Enum['absent','present'] $ensure = 'present',
  Boolean                  $fips   = false
){

  if ! ($name =~ /^\S+$/) {
    fail("tftpboot::linux_model '${name}' invalid: name cannot have whitespace")
  }

  include 'tftpboot'

  $install_dir = $::tftpboot::install_root_dir
  file { "${install_dir}/pxelinux.cfg/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template('tftpboot/entry.erb'),
    mode    => '0644',
    seltype => 'tftpdir_t'
  }
}
