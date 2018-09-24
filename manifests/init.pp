# class tftpboot
#
# Sets up a tftpboot server.
#
# @param tftpboot_root_dir The root directory of tftboot.
#
# @param linux_install_dir The name of a sub-directory of
#   $tftpboot_root_dir (relative path) that contains files used
#   to PXEboot a server.
#
# @param trusted_nets  See only_from in xinetd.conf(5).
#   This will be converted to DDQ format automatically.
#
# @param rsync_enabled Whether to use rsync to efficiently pull initial
#   boot files from a central location (i.e., the rsync server) and
#   install them into `$tftpboot_root_dir/$linux_install_dir`.  When
#   set to `false`, you must provide some other mechanism to install
#   the initial boot files into $tftpboot_root_dir/$linux_install_dir.
#
# @param rsync_source The source of the content to be rsync'd.
#
# @param rsync_server The rsync server FQDN from which to pull the
#   tftpboot configuration. This should contain the entire PXEboot
#   hierarchy if you wish to use this to PXEboot servers.
#
# @param rsync_timeout The connection timeout for the rsync connections.
#
# @param purge_configs Determines if non puppet-managed configuration
#   files in `$tftpboot_root_dir/$linux_install_dir/pxelinux.cfg`
#   get purged. At this time, there is no purge mechanism for
#   `$tftpboot_root_dir/$linux_install_dir/efi`, which contains both
#   configuration and initial boot files.
#
# @param use_os_files If `true`, use the OS provided syslinux and grub
#   packages to obtain the initial boot files (e.g., `pxelinux.0`,
#   `menu.c32`, `grub.efi`, `grubx64.efi`, `shim.efi`).
#
# @param os_file_info Hash of Hashes containing the mapping of OS
#   packages to initial boot files.  The outer Hash key is either
#   'bios' or 'efi', corresponding to BIOS or UEFI boot, respectively.
#   The inner Hash is a Hash of Arrays. Each inner Hash key is an
#   OS package.  Each inner Hash value is the list of PXEboot files
#   provided by the named package.  See the module data for specifics.
#
# @param package_ensure The ensure status of packages to be installed.
#
#
# @author https://github.com/simp/pupmod-simp-tftpboot/graphs/contributors
#
class tftpboot (
  Hash                 $os_file_info,     # data-in-modules
  Stdlib::Absolutepath $tftpboot_root_dir = '/var/lib/tftpboot',
  String               $linux_install_dir = 'linux-install',
  Simplib::Netlist     $trusted_nets      = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'] }),
  Boolean              $rsync_enabled     = true,
  String               $rsync_source      = "tftpboot_${::environment}_${facts['os']['name']}/*",
  String               $rsync_server      = simplib::lookup('simp_options::rsync::server',  { 'default_value' => '127.0.0.1' }),
  Integer              $rsync_timeout     = simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2 }),
  Boolean              $purge_configs     = true,
  Boolean              $use_os_files      = true,
  String               $package_ensure    = simplib::lookup('simp_options::package_ensure', { 'default_value' => 'installed' })
){
  $install_root_dir = "${tftpboot_root_dir}/${linux_install_dir}"

  include 'tftpboot::config'
  include 'xinetd'

  package { 'tftp-server': ensure => $::tftpboot::package_ensure }

  Package['tftp-server'] -> Class['tftpboot::config']

  xinetd::service { 'tftp':
    x_type         => 'UNLISTED',
    socket_type    => 'dgram',
    protocol       => 'udp',
    x_wait         => 'yes',
    port           => 69,
    server         => '/usr/sbin/in.tftpd',
    server_args    => "-s ${tftpboot_root_dir}",
    libwrap_name   => 'in.tftpd',
    per_source     => 11,
    cps            => [100,2],
    flags          => ['IPv4'],
    trusted_nets   => nets2ddq($trusted_nets),
    log_on_success => ['HOST', 'PID', 'DURATION'],
    require        => [ Package['tftp-server'], File[$tftpboot_root_dir] ]
  }
}
