# Installs boot files from OS files, ensuring the OS packages
# containing those files are present.
#
# @param os_file_info A Hash in which each key is the OS package
#   containing boot files and its corresponding value is an array
#   of those boot files
#
# @param boot_install_dir The directory into which copies of the
#   OS boot files will be copied
#
# @param package_ensure The ensure status of packages to be installed
#
# @return [Nil]
#
# @example BIOS boot files
#   file_info = {
#     'syslinux-tftpboot' =>
#        [ "/var/lib/tftpboot/menu.c32",
#         "/var/lib/tftpboot/pxelinux.0" ]
#   }
#   boot_dir = '/var/lib/tftpboot/linux-install'
#
#   tftpboot::install_boot_files(file_info, boot_dir, 'latest')
#
function tftpboot::install_boot_files(
    Hash  $os_file_info,
    String $boot_install_dir,
    String $package_ensure
) {
  # Ensure all the OS packages containing the needed boot files
  # are installed
  $os_packages = keys($os_file_info)
  $os_packages.each |String $pkg_name| {
    unless defined(Package[$pkg_name]) {
      package { $pkg_name: ensure => $package_ensure }
    }
  }

  # Install each boot file
  $os_file_info.each | String $pkg, Array $files| {
    $files.each | String $file | {
      $installed_file = sprintf('%s/%s',$boot_install_dir, basename($file))
      file { $installed_file:
        ensure  => 'file',
        owner   => 'root',
        group   => 'nobody',
        mode    => '0644',
        seltype => 'tftpdir_t',
        source  => "file://${file}",
        require => Package[$pkg]
      }
    }
  }
}
