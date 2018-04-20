# Configuration class called from tftpboot::config.
#
# @author https://github.com/simp/pupmod-simp-tftpboot/graphs/contributors
#
class tftpboot::config::bios {
  assert_private()

  # We're only tidying the top directory so that custom templates can be added
  # by hand to the templates directory created below.
  $install_dir = $::tftpboot::install_root_dir
  file { "${install_dir}/pxelinux.cfg":
    ensure       => 'directory',
    owner        => 'root',
    group        => 'nobody',
    mode         => '0640',
    seltype      => 'tftpdir_t',
    purge        => $::tftpboot::purge_configs,
    recurse      => true,
    recurselimit => '1',
    require      => File[ $install_dir ]
  }

  file { "${install_dir}/pxelinux.cfg/templates":
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    seltype => 'tftpdir_t',
    recurse => true,
  }

  if $::tftpboot::use_os_files {
    tftpboot::install_boot_files($::tftpboot::os_file_info['bios'],
      $install_dir, $::tftpboot::package_ensure)
  }
}
