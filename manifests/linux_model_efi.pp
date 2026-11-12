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
# @param ks The full URL to the location of the kickstart file. It is
#            passed to the installer as `inst.ks=`.
#
# @param extra Any other kernel parameters that you would like to pass at boot.
#              Use the `inst.`-prefixed options (`inst.repo=`, `inst.stage2=`)
#              and `ip=dhcp`; the un-prefixed legacy spellings (`repo=`,
#              `ksdevice=`) are ignored by EL9 and EL10.
#
# @param ensure Set or delete this entry.  Options: ['absent'|'present']
#
# @param fips If true, boots the installer with `fips=1`, which makes the
#             installed host FIPS-enabled. The EL8/9/10 kickstarts take FIPS
#             mode from this option. Defaults to `simp_options::fips`.
#
# @param legacy_grub Whether this host uses legacy grub.
#
define tftpboot::linux_model_efi (
  String                   $kernel,
  String                   $initrd,
  String                   $ks,
  Optional[String]         $extra       = undef,
  Enum['absent','present'] $ensure      = 'present',
  Boolean                  $fips        = simplib::lookup('simp_options::fips', { 'default_value' => false }),
  Boolean                  $legacy_grub = false
) {
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
    $_kernel = "/${tftpboot::linux_install_dir}/${kernel}"
    $_initrd = "/${tftpboot::linux_install_dir}/${initrd}"
    $_template = 'tftpboot/entry_efi.erb'
  }

  $install_dir = $tftpboot::install_root_dir

  file { "${install_dir}/efi/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template($_template),
    mode    => '0644',
    seltype => 'tftpdir_t',
  }
}
