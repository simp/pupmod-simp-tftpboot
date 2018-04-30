# Configuration class called from tftpboot::config.
#
# @author https://github.com/simp/pupmod-simp-tftpboot/graphs/contributors
#
class tftpboot::config::efi {
  assert_private()


  $_install_dir = "${::tftpboot::install_root_dir}/efi"
  file { $_install_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    seltype => 'tftpdir_t'
  }

  file { "${_install_dir}/templates":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    seltype => 'tftpdir_t'
  }

  if $::tftpboot::use_os_files {
    # Ensure all the OS packages containing the needed boot files
    # are installed
    $_os_packages = keys($::tftpboot::os_file_info['efi'])
    $_os_packages.each |String $pkg_name| {
      unless defined(Package[$pkg_name]) {
        package { $pkg_name: ensure => $::tftpboot::package_ensure }
      }
    }

    # Install each boot file
    $::tftpboot::os_file_info['efi'].each | String $pkg, Array $files| {
      $files.each | String $file | {
        $installed_file = sprintf('%s/%s',$_install_dir, basename($file))
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
}
