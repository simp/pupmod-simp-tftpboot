require 'spec_helper'

default_rsync_exclude = {
  'centos-6-x86_64'      => ['pxelinux.cfg', 'menu.c32', 'pxelinux.0', 'grub.efi'],
  'centos-7-x86_64'      => ['pxelinux.cfg', 'menu.c32', 'pxelinux.0', 'grubx64.efi', 'shim.efi'],
  'redhat-6-x86_64'      => ['pxelinux.cfg', 'menu.c32', 'pxelinux.0', 'grub.efi'],
  'redhat-7-x86_64'      => ['pxelinux.cfg', 'menu.c32', 'pxelinux.0', 'grubx64.efi', 'shim.efi'],
  'oraclelinux-6-x86_64' => ['pxelinux.cfg', 'menu.c32', 'pxelinux.0', 'grub.efi'],
  'oraclelinux-7-x86_64' => ['pxelinux.cfg', 'menu.c32', 'pxelinux.0', 'grubx64.efi', 'shim.efi']
}

default_packages = {
  'centos-6-x86_64'      => ['tftp-server', 'syslinux-tftpboot', 'grub'],
  'centos-7-x86_64'      => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'redhat-6-x86_64'      => ['tftp-server', 'syslinux-tftpboot', 'grub'],
  'redhat-7-x86_64'      => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'oraclelinux-6-x86_64' => ['tftp-server', 'syslinux-tftpboot', 'grub'],
  'oraclelinux-7-x86_64' => ['tftp-server', 'syslinux', 'grub2-efi-x64', 'shim-x64'],
}

default_boot_files = {
  'centos-6-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      :src => '/var/lib/tftpboot/menu.c32',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      :src => '/var/lib/tftpboot/pxelinux.0',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/efi/grub.efi' => {
      :src => '/boot/efi/EFI/redhat/grub.efi',
      :pkg => 'grub'
    },
  },
  'centos-7-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      :src => '/var/lib/tftpboot/menu.c32',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      :src => '/var/lib/tftpboot/pxelinux.0',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      :src => '/boot/efi/EFI/centos/grubx64.efi',
      :pkg => 'grub2-efi-x64'
    },
    '/var/lib/tftpboot/linux-install/efi/shim.efi' => {
      :src => '/boot/efi/EFI/centos/shim.efi',
      :pkg => 'shim-x64'
    }
  },
  'redhat-6-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      :src => '/var/lib/tftpboot/menu.c32',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      :src => '/var/lib/tftpboot/pxelinux.0',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/efi/grub.efi' => {
      :src => '/boot/efi/EFI/redhat/grub.efi',
      :pkg => 'grub'
    },
  },
  'redhat-7-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      :src => '/var/lib/tftpboot/menu.c32',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      :src => '/var/lib/tftpboot/pxelinux.0',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      :src => '/boot/efi/EFI/redhat/grubx64.efi',
      :pkg => 'grub2-efi-x64'
    },
    '/var/lib/tftpboot/linux-install/efi/shim.efi' => {
      :src => '/boot/efi/EFI/redhat/shim.efi',
      :pkg => 'shim-x64'
    }
  },
  'oraclelinux-6-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      :src => '/var/lib/tftpboot/menu.c32',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      :src => '/var/lib/tftpboot/pxelinux.0',
      :pkg => 'syslinux-tftpboot'
    },
    '/var/lib/tftpboot/linux-install/efi/grub.efi' => {
      :src => '/boot/efi/EFI/redhat/grub.efi',
      :pkg => 'grub'
    },
  },
  'oraclelinux-7-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      :src => '/usr/share/syslinux/menu.c32',
      :pkg => 'syslinux'
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      :src => '/usr/share/syslinux/pxelinux.0',
      :pkg => 'syslinux'
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      :src => '/boot/efi/EFI/redhat/grubx64.efi',
      :pkg => 'grub2-efi-x64'
    },
    '/var/lib/tftpboot/linux-install/efi/shim.efi' => {
      :src => '/boot/efi/EFI/redhat/shim.efi',
      :pkg => 'shim-x64'
    }
  }
}


describe 'tftpboot' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
     let(:facts) { facts }

      context 'with default parameters' do

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to create_class('tftpboot') }
        it { is_expected.to create_class('tftpboot::config') }
        it { is_expected.to create_class('tftpboot::config::bios') }
        it { is_expected.to create_class('tftpboot::config::efi') }

        it do
          is_expected.to contain_file('/var/lib/tftpboot').with({
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0750',
            'seltype' => 'tftpdir_t'
          })
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install').with({
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t'
          })
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg').with({
            'ensure'       => 'directory',
            'owner'        => 'root',
            'group'        => 'nobody',
            'mode'         => '0640',
            'seltype'      => 'tftpdir_t',
            'purge'        => true,
            'recurse'      => true,
            'recurselimit' => 1,
            'require'      => ['File[/var/lib/tftpboot/linux-install]']
          })
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg/templates').with({
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t',
            'recurse' => true,
          })
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi').with({
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t'
          })
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates').with({
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t'
          })
        end

        default_packages[os].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('installed') }
        end

        default_boot_files[os].each do |file, info_hash|
          it do
            is_expected.to contain_file(file).with( {
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'nobody',
              'mode'    => '0644',
              'seltype' => 'tftpdir_t',
              'source'  => "file://#{info_hash[:src]}",
              'require' => "Package[#{info_hash[:pkg]}]"
            } )
          end
        end


        it do
          expected_exclude = default_rsync_exclude[os]
          is_expected.to contain_rsync('tftpboot').with({
            'user' => "tftpboot_rsync_#{environment}_#{facts[:os][:name].downcase}",
            'password' => /^.+$/,
            'source' => "tftpboot_#{environment}_#{facts[:os][:name]}/*",
            'target' => '/var/lib/tftpboot',
            'server' => 'rsync.bar.baz',
            'timeout' => 2,
            'exclude' => expected_exclude
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
            'server_args' => '-s /var/lib/tftpboot',
            'libwrap_name' => 'in.tftpd',
            'per_source' => 11,
            'cps' => [100,2],
            'flags' => ['IPv4'],
            'trusted_nets' => /1.2.0.0/,
            'log_on_success' => ['HOST','PID','DURATION'],
            'require' => [ 'Package[tftp-server]', 'File[/var/lib/tftpboot]' ]

          })
        end
      end

      context 'with install location overrides' do
        let(:params) {{
          :tftpboot_root_dir => '/opt/tftpboot',
          :linux_install_dir => 'install'
        }}
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/opt/tftpboot').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/pxelinux.cfg').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/pxelinux.cfg/templates').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/efi').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/efi/templates').with_ensure('directory') }
        default_boot_files[os].each do |file, info_hash|
          expected_file = file.gsub('/var/lib/tftpboot','/opt/tftpboot')
          expected_file.gsub!('linux-install', 'install')
          it { is_expected.to contain_file(expected_file).with_source("file://#{info_hash[:src]}") }
        end
        it { is_expected.to contain_rsync('tftpboot').with_target('/opt/tftpboot') }
        it { is_expected.to contain_xinetd__service('tftp').with('server_args' => '-s /opt/tftpboot') }
      end

      context 'with rsync_enabled = false' do
        let(:params) {{
          :rsync_enabled => false
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to_not contain_rsync('tftpboot') }
      end

      context 'with purge_configs => false' do
        let(:params) {{
          :purge_configs => false
        }}

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg').with_purge(false) }
      end

      context 'with use_os_files => false' do
        let(:params) {{
          :use_os_files => false
        }}

        it { is_expected.to compile.with_all_deps }

        default_packages[os].each do |pkg|
          next if pkg == 'tftp-server'
          it { is_expected.to_not contain_package(pkg) }
        end

        default_boot_files[os].each do |file, info_hash|
          it { is_expected.to_not contain_file(file) }
        end

        it { is_expected.to contain_rsync('tftpboot').with_exclude(['pxelinux.cfg']) }
      end

      context "with package_ensure => 'latest'" do
        let(:params) {{
          :package_ensure => 'latest'
        }}

        it { is_expected.to compile.with_all_deps }
        default_packages[os].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('latest') }
        end
      end
    end
  end
end
