# Configuration class called from tftpboot::config.
#
# @author https://github.com/simp/pupmod-simp-tftpboot/graphs/contributors
#
class tftpboot::config::efi {
  assert_private()


  $install_dir = "${::tftpboot::install_root_dir}/efi"
  file { $install_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    seltype => 'tftpdir_t'
  }

  file { "${install_dir}/templates":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    seltype => 'tftpdir_t'
  }

  if $::tftpboot::use_os_files {
    tftpboot::install_boot_files($::tftpboot::os_file_info['efi'],
      $install_dir, $::tftpboot::package_ensure)
  }
}
