require 'spec_helper'

default_rsync_exclude = {
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
}

default_packages = {
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
}

default_boot_files = {
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
    }
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
    }
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
    }
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
    }
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
    }
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
    }
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
    }
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
    }
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
    }
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

        default_packages[os].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('installed') }
        end

        default_boot_files[os].each do |file, info_hash|
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
          expected_exclude = default_rsync_exclude[os]
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
        default_boot_files[os].each do |file, info_hash|
          expected_file = file.gsub('/var/lib/tftpboot', '/opt/tftpboot')
          expected_file.gsub!('linux-install', 'install')
          it { is_expected.to contain_file(expected_file).with_source("file://#{info_hash[:src]}") }
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

        default_packages[os].each do |pkg|
          next if pkg == 'tftp-server'
          it { is_expected.not_to contain_package(pkg) }
        end

        default_boot_files[os].each_key do |file|
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
        default_packages[os].each do |pkg|
          it { is_expected.to contain_package(pkg).with_ensure('latest') }
        end
      end
    end
  end
end
