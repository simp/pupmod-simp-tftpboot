# class tftpboot
#
# Sets up a tftpboot server.
#
# @param trusted_nets  See only_from in xinetd.conf(5).
#   This will be converted to DDQ format automatically.
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
#   files in /tftpboot/linux-install/pxelinux.cfg get purged.
#
# @param use_os_files If true, use the OS provided syslinux packages
#   to obtain the pxelinux.0 file.
#
# @todo Ensure that this module can be used with any target location.
#
# @author Trevor Vaughan <tvaughan@onyxpoint.com>
#
class tftpboot (
  Array[String]  $trusted_nets         = simplib::lookup('simp_options::trusted_nets', { 'default_value' => ['127.0.0.1', '::1'] }),
  String         $rsync_source         = "tftpboot_${::environment}_${facts['os']['name']}/*",
  String         $rsync_server         = simplib::lookup('simp_options::rsync::server',  { 'default_value' => '127.0.0.1' }),
  Integer        $rsync_timeout        = simplib::lookup('simp_options::rsync::timeout', { 'default_value' => 2 }),
  Boolean        $purge_configs        = true,
  Boolean        $use_os_files         = true
){
  validate_net_list($trusted_nets)

  include '::xinetd'
  include '::rsync'

  file { '/tftpboot':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0750',
    require => Package['tftp-server']
  }

  file { '/tftpboot/linux-install':
    ensure => 'directory',
    owner  => 'root',
    group  => 'nobody',
    mode   => '0640',
  }

  # We're only tidying the top directory so that custom templates can be added
  # by hand to the templates directory created below.
  file { '/tftpboot/linux-install/pxelinux.cfg':
    ensure       => 'directory',
    owner        => 'root',
    group        => 'nobody',
    mode         => '0640',
    purge        => $purge_configs,
    recurse      => true,
    recurselimit => '1',
    require      => [
      Package['tftp-server'],
      File['/tftpboot/linux-install']
    ]
  }

  file { '/tftpboot/linux-install/pxelinux.cfg/templates':
    ensure  => 'directory',
    owner   => 'root',
    group   => 'nobody',
    mode    => '0640',
    recurse => true,
    require => Package['tftp-server'],
  }

  package { 'tftp-server': ensure => 'latest' }

  if $use_os_files {
    package { 'syslinux-tftpboot': ensure => 'latest' }

    file { '/tftpboot/linux-install/pxelinux.0':
      ensure  => 'file',
      owner   => 'root',
      group   => 'nobody',
      mode    => '0644',
      source  => 'file:///var/lib/tftpboot/pxelinux.0',
      require => Package['syslinux-tftpboot']
    }

    file { '/tftpboot/linux-install/menu.c32':
      ensure  => 'file',
      owner   => 'root',
      group   => 'nobody',
      mode    => '0644',
      source  => 'file:///var/lib/tftpboot/menu.c32',
      require => Package['syslinux-tftpboot']
    }

    $_rsync_exclude = [
      'pxelinux.cfg',
      'menu.c32',
      'pxelinux.0'
    ]
  }
  else {
    $_rsync_exclude = [ 'pxelinux.cfg' ]
  }
  $_downcase_osname = downcase($facts['os']['name'])

  rsync { 'tftpboot':
    user     => "tftpboot_rsync_${::environment}_${_downcase_osname}",
    password => passgen("tftpboot_rsync_${::environment}_${_downcase_osname}"),
    source   => $rsync_source,
    target   => '/tftpboot',
    server   => $rsync_server,
    timeout  => $rsync_timeout,
    exclude  => $_rsync_exclude
  }

  xinetd::service { 'tftp':
    x_type         => 'UNLISTED',
    socket_type    => 'dgram',
    protocol       => 'udp',
    x_wait         => 'yes',
    port           => 69,
    server         => '/usr/sbin/in.tftpd',
    server_args    => '-s /tftpboot',
    libwrap_name   => 'in.tftpd',
    per_source     => 11,
    cps            => [100,2],
    flags          => ['IPv4'],
    trusted_nets   => nets2ddq($trusted_nets),
    log_on_success => ['HOST', 'PID', 'DURATION']
  }
}
