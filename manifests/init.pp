# == Class: tftpboot
#
# Sets up a tftpboot server.
#
# == Parameters
#
# [*client_nets*]
#   See only_from in xinetd.conf(5).
#   This will be converted to DDQ format automatically.
#
# [*rsync_server*]
# Type: FQDN
# Default: hiera('rsync::server')
#   The rsync server from which to pull the tftpboot configuration.
#   This should contain the entire PXEboot hierarchy if you wish to
#   use this to PXEboot servers.
#
# [*rsync_timeout*]
# Type: Integer
# Default: hiera('rsync::timeout','2')
#   The connection timeout for the rsync connections.
#
# [*purge_configs*]
# Type: Boolean
# Default: True
#   Determines if non puppet-managed configuration files in
#   /tftpboot/linux-install/pxelinux.cfg get purged.
#
# == Authors
#
# * Trevor Vaughan <tvaughan@onyxpoint.com>
#
class tftpboot (
  $client_nets = hiera('client_nets'),
  $rsync_server = hiera('rsync::server'),
  $rsync_timeout = hiera('rsync::timeout','2'),
  $purge_configs = true
){
  include 'xinetd'
  include 'rsync'

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

  rsync { 'tftpboot':
    user     => 'tftpboot_rsync',
    password => passgen('tftpboot_rsync'),
    source   => 'tftpboot/*',
    target   => '/tftpboot',
    server   => $rsync_server,
    timeout  => $rsync_timeout,
    exclude  => 'pxelinux.cfg'
  }

  xinetd::service { 'tftp':
    x_type         => 'unlisted',
    socket_type    => 'dgram',
    protocol       => 'udp',
    x_wait         => 'yes',
    port           => '69',
    server         => '/usr/sbin/in.tftpd',
    server_args    => '-s /tftpboot',
    libwrap_name   => 'in.tftpd',
    per_source     => '11',
    cps            => '100 2',
    flags          => 'IPv4',
    only_from      => nets2ddq($client_nets),
    log_on_success => 'HOST PID DURATION'
  }

  validate_string($rsync_server)
  validate_net_list($client_nets)
  validate_integer($rsync_timeout)
  validate_bool($purge_configs)
}
