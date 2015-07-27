require 'spec_helper'

describe 'tftpboot' do

  it { should create_class('tftpboot') }

  it do
    should contain_file('/tftpboot').with({
      'ensure' => 'directory',
      'owner' => 'root',
      'group' => 'nobody',
      'mode' => '0750',
      'require' => "Package[tftp-server]"
    })
  end

  it do
    should contain_file('/tftpboot/linux-install').with({
      'ensure' => 'directory',
      'owner' => 'root',
      'group' => 'nobody',
      'mode' => '0640'
    })
  end

  it do
    should contain_file('/tftpboot/linux-install/pxelinux.cfg').with({
      'ensure' => 'directory',
      'owner' => 'root',
      'group' => 'nobody',
      'mode' => '0640',
      'purge' => true,
      'recurse' => true,
      'recurselimit' => '1',
      'require' => ['Package[tftp-server]', 'File[/tftpboot/linux-install]']
    })
  end

  it do
    should contain_file('/tftpboot/linux-install/pxelinux.cfg/templates').with({
      'ensure' => 'directory',
      'owner' => 'root',
      'group' => 'nobody',
      'mode' => '0640',
      'recurse' => true,
      'require' => 'Package[tftp-server]'
    })
  end

  it { should contain_package('tftp-server') }

  it do
    should contain_rsync('tftpboot').with({
      'user' => 'tftpboot_rsync',
      'password' => /^.+$/,
      'source' => 'tftpboot/*',
      'target' => '/tftpboot',
      'server' => 'rsync.bar.baz',
      'timeout' => '2',
      'exclude' => ['pxelinux.cfg','menu.c32','pxelinux.0']
    })
  end

  it do
    should contain_xinetd__service('tftp').with({
      'x_type' => 'unlisted',
      'socket_type' => 'dgram',
      'protocol' => 'udp',
      'x_wait' => 'yes',
      'port' => '69',
      'server' => '/usr/sbin/in.tftpd',
      'server_args' => '-s /tftpboot',
      'libwrap_name' => 'in.tftpd',
      'per_source' => '11',
      'cps' => '100 2',
      'flags' => 'IPv4',
      'only_from' => /1.2.0.0/,
      'log_on_success' => 'HOST PID DURATION'
    })
  end

  it do
    should contain_package('syslinux-tftpboot')
  end

  it do
    should contain_file('/tftpboot/linux-install/pxelinux.0').with_source('file:///var/lib/tftpboot/pxelinux.0')
    should contain_file('/tftpboot/linux-install/pxelinux.0').that_requires('Package[syslinux-tftpboot]')
  end

  it do
    should contain_file('/tftpboot/linux-install/menu.c32').with_source('file:///var/lib/tftpboot/menu.c32')
    should contain_file('/tftpboot/linux-install/menu.c32').that_requires('Package[syslinux-tftpboot]')
  end
end
