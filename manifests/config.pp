# Configuration class called from tftpboot.
#
# @author https://github.com/simp/pupmod-simp-tftpboot/graphs/contributors
#
class tftpboot::config {
  assert_private()

  file { $::tftpboot::tftpboot_root_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0750',
    seltype => 'tftpdir_t'
  }

  file { $::tftpboot::install_root_dir:
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    seltype => 'tftpdir_t'
  }

  contain 'tftpboot::config::bios'
  contain 'tftpboot::config::efi'

  if $::tftpboot::use_os_files {
    $_os_files = tftpboot::get_os_base_filenames($::tftpboot::os_file_info)
    $_rsync_exclude = [ 'pxelinux.cfg' ] + $_os_files
  } else {
    $_rsync_exclude = [ 'pxelinux.cfg' ]
  }

  $_downcase_osname = downcase($facts['os']['name'])

  if $::tftpboot::rsync_enabled {
    include 'rsync'

    rsync { 'tftpboot':
      user     => "tftpboot_rsync_${::environment}_${_downcase_osname}",
      password => simplib::passgen("tftpboot_rsync_${::environment}_${_downcase_osname}"),
      source   => $::tftpboot::rsync_source,
      target   => $::tftpboot::tftpboot_root_dir,
      server   => $::tftpboot::rsync_server,
      timeout  => $::tftpboot::rsync_timeout,
      exclude  => $_rsync_exclude
    }
  }
}
