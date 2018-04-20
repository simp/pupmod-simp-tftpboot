#
# Add a TFTPBoot Linux model entry for UEFI boot
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
# @param legacy_grub Whether this host uses legacy grub.
#
define tftpboot::linux_model_efi (
  String                   $kernel,
  String                   $initrd,
  String                   $ks,
  Optional[String]         $extra       = undef,
  Enum['absent','present'] $ensure      = 'present',
  Boolean                  $fips        = false,
  Boolean                  $legacy_grub = false
){

  if ! ($name =~ /^\S+$/) {
    fail("tftpboot::linux_model_efi '${name}' invalid: name cannot have whitespace")
  }

  include 'tftpboot'

  if $legacy_grub {
    # In legacy grub, the root directory for tftboot is ASSUMED to be
    # the directory in which the EFI grub configuration file resides.
    # In a SIMP system, however, the image directories are one directory
    # up.  So, to specify the correct location of the images and satisfy
    # a weak, legacy grub check for absolute paths to images, we have to
    # use '/../' here.
    $_kernel = "/../${kernel}"
    $_initrd = "/../${initrd}"
    $_template = 'tftpboot/entry_efi_legacy_grub.erb'
  } else {
    $_kernel = "/${::tftpboot::linux_install_dir}/${kernel}"
    $_initrd = "/${::tftpboot::linux_install_dir}/${initrd}"
    $_template = 'tftpboot/entry_efi.erb'
  }

  $install_dir = $::tftpboot::install_root_dir

  file { "${install_dir}/efi/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template($_template),
    mode    => '0644',
    seltype => 'tftpdir_t'
  }
}
