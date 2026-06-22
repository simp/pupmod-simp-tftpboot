require 'spec_helper'

DEFAULT_RSYNC_EXCLUDE = {
  'centos-9-x86_64'      => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'centos-10-x86_64'     => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'redhat-8-x86_64'      => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'redhat-9-x86_64'      => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'redhat-10-x86_64'     => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'oraclelinux-8-x86_64' => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'oraclelinux-9-x86_64' => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'rocky-8-x86_64'       => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'rocky-9-x86_64'       => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'almalinux-8-x86_64'   => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'almalinux-9-x86_64'   => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
  'almalinux-10-x86_64'  => ['pxelinux.cfg', 'chain.c32', 'ldlinux.c32', 'libcom32.c32', 'libutil.c32', 'memdisk', 'menu.c32', 'pxechn.c32', 'pxelinux.0', 'grubx64.efi', 'shimx64.efi'],
}.freeze

DEFAULT_PACKAGES = {
  'centos-9-x86_64'      => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'centos-10-x86_64'     => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'redhat-8-x86_64'      => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'redhat-9-x86_64'      => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'redhat-10-x86_64'     => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'oraclelinux-8-x86_64' => ['tftp-server', 'syslinux', 'grub2-efi-x64', 'shim-x64'],
  'oraclelinux-9-x86_64' => ['tftp-server', 'syslinux', 'grub2-efi-x64', 'shim-x64'],
  'rocky-8-x86_64'       => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'rocky-9-x86_64'       => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'almalinux-8-x86_64'   => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'almalinux-9-x86_64'   => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
  'almalinux-10-x86_64'  => ['tftp-server', 'syslinux-tftpboot', 'grub2-efi-x64', 'shim-x64'],
}.freeze

DEFAULT_BOOT_FILES = {
  'centos-9-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/centos/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/centos/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'centos-10-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/centos/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/centos/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'redhat-8-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/redhat/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/redhat/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'redhat-9-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/redhat/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/redhat/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'redhat-10-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/redhat/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/redhat/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'oraclelinux-8-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/usr/share/syslinux/menu.c32',
      pkg: 'syslinux',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/usr/share/syslinux/pxelinux.0',
      pkg: 'syslinux',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/redhat/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/redhat/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'oraclelinux-9-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/usr/share/syslinux/menu.c32',
      pkg: 'syslinux',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/usr/share/syslinux/pxelinux.0',
      pkg: 'syslinux',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/redhat/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/redhat/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'rocky-8-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/rocky/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/rocky/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'rocky-9-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/rocky/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/rocky/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'almalinux-8-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/almalinux/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/almalinux/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'almalinux-9-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/almalinux/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/almalinux/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
  'almalinux-10-x86_64' => {
    '/var/lib/tftpboot/linux-install/menu.c32' => {
      src: '/tftpboot/menu.c32',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/pxelinux.0' => {
      src: '/tftpboot/pxelinux.0',
      pkg: 'syslinux-tftpboot',
    },
    '/var/lib/tftpboot/linux-install/efi/grubx64.efi' => {
      src: '/boot/efi/EFI/almalinux/grubx64.efi',
      pkg: 'grub2-efi-x64',
    },
    '/var/lib/tftpboot/linux-install/efi/shimx64.efi' => {
      src: '/boot/efi/EFI/almalinux/shimx64.efi',
      pkg: 'shim-x64',
    },
  },
}.freeze

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
          is_expected.to contain_file('/var/lib/tftpboot').with(
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0750',
            'seltype' => 'tftpdir_t',
          )
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install').with(
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t',
          )
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg').with(
            'ensure'       => 'directory',
            'owner'        => 'root',
            'group'        => 'nobody',
            'mode'         => '0640',
            'seltype'      => 'tftpdir_t',
            'purge'        => true,
            'recurse'      => true,
            'recurselimit' => 1,
            'require'      => ['File[/var/lib/tftpboot/linux-install]'],
          )
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg/templates').with(
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t',
            'recurse' => true,
          )
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi').with(
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t',
          )
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates').with(
            'ensure'  => 'directory',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0640',
            'seltype' => 'tftpdir_t',
          )
        end

        DEFAULT_PACKAGES[os].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('installed') }
        end

        DEFAULT_BOOT_FILES[os].each do |file, info_hash|
          it do
            is_expected.to contain_file(file).with(
              'ensure'  => 'file',
              'owner'   => 'root',
              'group'   => 'nobody',
              'mode'    => '0644',
              'seltype' => 'tftpdir_t',
              'source'  => "file://#{info_hash[:src]}",
              'require' => "Package[#{info_hash[:pkg]}]",
            )
          end
        end

        it do
          expected_exclude = DEFAULT_RSYNC_EXCLUDE[os]
          is_expected.to contain_rsync('tftpboot').with(
            'user'     => "tftpboot_rsync_#{environment}_#{facts[:os][:name].downcase}",
            'password' => %r{^.+$},
            'source'   => "tftpboot_#{environment}_#{facts[:os][:name]}/*",
            'target'   => '/var/lib/tftpboot',
            'server'   => 'rsync.bar.baz',
            'timeout'  => 2,
            'exclude'  => expected_exclude,
          )
        end

        it do
          is_expected.to contain_service('tftp.socket').with(
            'ensure' => 'running',
            'enable' => 'true',
          )
        end
      end

      context 'with install location overrides' do
        let(:params) do
          {
            tftpboot_root_dir: '/opt/tftpboot',
            linux_install_dir: 'install',
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/opt/tftpboot').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/pxelinux.cfg').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/pxelinux.cfg/templates').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/efi').with_ensure('directory') }
        it { is_expected.to contain_file('/opt/tftpboot/install/efi/templates').with_ensure('directory') }
        DEFAULT_BOOT_FILES[os].each do |file, info_hash|
          it {
            expected_file = file.gsub('/var/lib/tftpboot', '/opt/tftpboot').gsub('linux-install', 'install')
            is_expected.to contain_file(expected_file).with_source("file://#{info_hash[:src]}")
          }
        end
        it { is_expected.to contain_rsync('tftpboot').with_target('/opt/tftpboot') }
        it { is_expected.to contain_service('tftp.socket') }
      end

      context 'with rsync_enabled = false' do
        let(:params) do
          {
            rsync_enabled: false,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.not_to contain_rsync('tftpboot') }
      end

      context 'with purge_configs => false' do
        let(:params) do
          {
            purge_configs: false,
          }
        end

        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg').with_purge(false) }
      end

      context 'with use_os_files => false' do
        let(:params) do
          {
            use_os_files: false,
          }
        end

        it { is_expected.to compile.with_all_deps }

        DEFAULT_PACKAGES[os].each do |pkg|
          next if pkg == 'tftp-server'
          it { is_expected.not_to contain_package(pkg) }
        end

        DEFAULT_BOOT_FILES[os].each_key do |file|
          it { is_expected.not_to contain_file(file) }
        end

        it { is_expected.to contain_rsync('tftpboot').with_exclude(['pxelinux.cfg']) }
      end

      context "with package_ensure => 'latest'" do
        let(:params) do
          {
            package_ensure: 'latest',
          }
        end

        it { is_expected.to compile.with_all_deps }
        DEFAULT_PACKAGES[os].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('latest') }
        end
      end
    end
  end
end
