require 'spec_helper'

describe 'tftpboot' do
  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) { facts }

        it { is_expected.to create_class('tftpboot') }

        it do
          is_expected.to contain_file('/tftpboot').with({
            'ensure' => 'directory',
            'owner' => 'root',
            'group' => 'nobody',
            'mode' => '0750',
            'require' => "Package[tftp-server]"
          })
        end

        it do
          is_expected.to contain_file('/tftpboot/linux-install').with({
            'ensure' => 'directory',
            'owner' => 'root',
            'group' => 'nobody',
            'mode' => '0640'
          })
        end

        it do
          is_expected.to contain_file('/tftpboot/linux-install/pxelinux.cfg').with({
            'ensure' => 'directory',
            'owner' => 'root',
            'group' => 'nobody',
            'mode' => '0640',
            'purge' => true,
            'recurse' => true,
            'recurselimit' => 1,
            'require' => ['Package[tftp-server]', 'File[/tftpboot/linux-install]']
          })
        end

        it do
          is_expected.to contain_file('/tftpboot/linux-install/pxelinux.cfg/templates').with({
            'ensure' => 'directory',
            'owner' => 'root',
              'group' => 'nobody',
            'mode' => '0640',
            'recurse' => true,
            'require' => 'Package[tftp-server]'
          })
        end
  
        it { is_expected.to contain_package('tftp-server') }

        it do
          is_expected.to contain_rsync('tftpboot').with({
            'user' => "tftpboot_rsync_#{environment}_#{facts[:os][:name].downcase}",
              'password' => /^.+$/,
            'source' => "tftpboot_#{environment}_#{facts[:os][:name]}/*",
            'target' => '/tftpboot',
            'server' => 'rsync.bar.baz',
            'timeout' => 2,
            'exclude' => ['pxelinux.cfg','menu.c32','pxelinux.0']
          })
        end

        it do
          is_expected.to contain_xinetd__service('tftp').with({
            'x_type' => 'UNLISTED',
            'socket_type' => 'dgram',
            'protocol' => 'udp',
            'x_wait' => 'yes',
            'port' => 69,
            'server' => '/usr/sbin/in.tftpd',
            'server_args' => '-s /tftpboot',
            'libwrap_name' => 'in.tftpd',
            'per_source' => 11,
            'cps' => [100,2],
            'flags' => ['IPv4'],
            'trusted_nets' => /1.2.0.0/,
            'log_on_success' => ['HOST','PID','DURATION']
          })
        end

        it do
          is_expected.to contain_package('syslinux-tftpboot')
        end

        it do
          is_expected.to contain_file('/tftpboot/linux-install/pxelinux.0').with_source('file:///var/lib/tftpboot/pxelinux.0')
          is_expected.to contain_file('/tftpboot/linux-install/pxelinux.0').that_requires('Package[syslinux-tftpboot]')
        end

        it do
          is_expected.to contain_file('/tftpboot/linux-install/menu.c32').with_source('file:///var/lib/tftpboot/menu.c32')
          is_expected.to contain_file('/tftpboot/linux-install/menu.c32').that_requires('Package[syslinux-tftpboot]')
        end
      end
    end
  end
end
