require 'spec_helper'

describe 'tftpboot::install_boot_files' do
  context 'with an empty hash input' do
    it 'should run without error' do
      file_info      = {}
      boot_dir       = '/var/lib/tftpboot/linux-install'
      package_ensure = 'latest'

      is_expected.to run.with_params(file_info,boot_dir,package_ensure)
    end
  end

  context 'with a simple hash input' do
    it 'should create 1 package and 1 file resource' do
      file_info      = { 'grub' => ['/boot/efi/EFI/redhat/grub.efi'] }
      boot_dir       = '/var/lib/tftpboot/linux-install/efi'
      package_ensure = 'installed'

      is_expected.to run.with_params(file_info,boot_dir,package_ensure)
      resource = catalogue.resource('Package', 'grub')
      expect(resource).to_not be_nil
      expect(resource[:ensure]).to eq 'installed'

      resource = catalogue.resource('File', '/var/lib/tftpboot/linux-install/efi/grub.efi')
      expect(resource).to_not be_nil
      expect(resource[:ensure]).to eq 'file'
      expect(resource[:owner]).to eq 'root'
      expect(resource[:group]).to eq 'nobody'
      expect(resource[:mode]).to eq '0644'
      expect(resource[:seltype]).to eq 'tftpdir_t'
      expect(resource[:source]).to eq 'file:///boot/efi/EFI/redhat/grub.efi'
      expect(resource[:require].to_s).to eq 'Package[grub]'
    end
  end

  context 'with a complex hash input' do
    it 'should create 2 package and 3 file resources' do
      file_info = {
        'grub2-efi-x64' => [
          '/boot/efi/EFI/centos/grubx64.efi'
        ],
        'shim-x64' => [
          '/boot/efi/EFI/centos/shim.efi',
          '/boot/efi/EFI/centos/shimx64.efi'
        ]
      }
      boot_dir       = '/var/lib/tftpboot/linux-install/efi'
      package_ensure = 'latest'

      is_expected.to run.with_params(file_info,boot_dir,package_ensure)

      resource = catalogue.resource('Package', 'grub2-efi-x64')
      expect(resource).to_not be_nil
      expect(resource[:ensure]).to eq 'latest'

      resource = catalogue.resource('Package', 'shim-x64')
      expect(resource).to_not be_nil
      expect(resource[:ensure]).to eq 'latest'

      resource = catalogue.resource('File', '/var/lib/tftpboot/linux-install/efi/grubx64.efi')
      expect(resource[:ensure]).to eq 'file'
      expect(resource[:owner]).to eq 'root'
      expect(resource[:group]).to eq 'nobody'
      expect(resource[:mode]).to eq '0644'
      expect(resource[:seltype]).to eq 'tftpdir_t'
      expect(resource[:source]).to eq 'file:///boot/efi/EFI/centos/grubx64.efi'
      expect(resource[:require].to_s).to eq 'Package[grub2-efi-x64]'

      resource = catalogue.resource('File', '/var/lib/tftpboot/linux-install/efi/shim.efi')
      expect(resource[:ensure]).to eq 'file'
      expect(resource[:owner]).to eq 'root'
      expect(resource[:group]).to eq 'nobody'
      expect(resource[:mode]).to eq '0644'
      expect(resource[:seltype]).to eq 'tftpdir_t'
      expect(resource[:source]).to eq 'file:///boot/efi/EFI/centos/shim.efi'
      expect(resource[:require].to_s).to eq 'Package[shim-x64]'

      resource = catalogue.resource('File', '/var/lib/tftpboot/linux-install/efi/shimx64.efi')
      expect(resource[:ensure]).to eq 'file'
      expect(resource[:owner]).to eq 'root'
      expect(resource[:group]).to eq 'nobody'
      expect(resource[:mode]).to eq '0644'
      expect(resource[:seltype]).to eq 'tftpdir_t'
      expect(resource[:source]).to eq 'file:///boot/efi/EFI/centos/shimx64.efi'
      expect(resource[:require].to_s).to eq 'Package[shim-x64]'
    end
  end

end
