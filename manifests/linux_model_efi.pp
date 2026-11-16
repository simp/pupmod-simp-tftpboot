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
#              Use the `inst.`-prefixed installer options (`inst.repo=`,
#              `inst.stage2=`). The un-prefixed legacy spellings (`ks=`,
#              `repo=`, `ksdevice=`, `stage2=`, `method=`) are ignored by EL9
#              and EL10, and a warning is logged when `extra` contains
#              one.
#
#              On a host with several NICs, name the interface the
#              installer should use, e.g. `ip=eth2:dhcp` or
#              `bootdev=eth2 ip=dhcp`; grub2 has no equivalent of pxelinux's
#              `IPAPPEND 2`, so without one dracut tries DHCP on every NIC.
#
# @param ensure Set or delete this entry.  Options: ['absent'|'present']
#
# @param fips If true, boots the installer with `fips=1`, which makes the
#             installed host FIPS-enabled. The EL8/9/10 kickstarts take FIPS
#             mode from this option. Defaults to `simp_options::fips`.
#             This *may not work* with all initrd images: an initrd built
#             without dracut's `fips` module can fail to boot with `fips=1`.
#             Set `fips => false` on such a model.
#
define tftpboot::linux_model_efi (
  String                   $kernel,
  String                   $initrd,
  String                   $ks,
  Optional[String]         $extra       = undef,
  Enum['absent','present'] $ensure      = 'present',
  Boolean                  $fips        = simplib::lookup('simp_options::fips', { 'default_value' => false }),
) {
  if ! ($name =~ /^\S+$/) {
    fail("tftpboot::linux_model_efi '${name}' invalid: name cannot have whitespace")
  }

  if $extra and $extra =~ /(^|\s)(ks|repo|ksdevice|stage2|method)=/ {
    warning("tftpboot::linux_model_efi '${name}': `extra` contains un-prefixed installer options (ks=, repo=, ksdevice=, stage2=, method=), which EL9 and EL10 ignore. Use the inst. prefix (for example inst.repo=).")
  }

  include 'tftpboot'

  $_kernel = "/${tftpboot::linux_install_dir}/${kernel}"
  $_initrd = "/${tftpboot::linux_install_dir}/${initrd}"
  $_template = 'tftpboot/entry_efi.erb'

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
