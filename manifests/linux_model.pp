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
define tftpboot::linux_model (
  String                   $kernel,
  String                   $initrd,
  String                   $ks,
  Optional[String]         $extra  = undef,
  Enum['absent','present'] $ensure = 'present',
  Boolean                  $fips   = simplib::lookup('simp_options::fips', { 'default_value' => false })
) {
  if ! ($name =~ /^\S+$/) {
    fail("tftpboot::linux_model '${name}' invalid: name cannot have whitespace")
  }

  include 'tftpboot'

  $install_dir = $tftpboot::install_root_dir
  file { "${install_dir}/pxelinux.cfg/templates/${name}":
    ensure  => $ensure,
    owner   => 'root',
    group   => 'nobody',
    content => template('tftpboot/entry.erb'),
    mode    => '0644',
    seltype => 'tftpdir_t',
  }
}
