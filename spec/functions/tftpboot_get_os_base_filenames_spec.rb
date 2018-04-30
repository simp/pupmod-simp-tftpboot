require 'spec_helper'

describe 'tftpboot::get_os_base_filenames' do
  context 'with an empty hash input' do
    input = {}
    expected_output = []
    it { is_expected.to run.with_params(input).and_return(expected_output) }
  end

  context 'with a simple hash input' do
    input = {
      'efi' => {
        'grub' => ['/boot/efi/EFI/redhat/grub.efi']
      }
    }
    expected_output = [ 'grub.efi' ]
    it { is_expected.to run.with_params(input).and_return(expected_output) }
  end

  context 'with a complex hash input' do
    input = {
      'bios' => {
        'syslinux-tftpboot' => [
          '/var/lib/tftpboot/menu.c32',
          '/var/lib/tftpboot/pxelinux.0',
         ]
       },
       'efi' => {
         'grub2-efi-x64' => [
           '/boot/efi/EFI/centos/grubx64.efi'
         ],
         'shim-x64' => [
           '/boot/efi/EFI/centos/shim.efi',
           '/boot/efi/EFI/centos/shimx64.efi'
         ]
       }
    }
    expected_output = [
      'menu.c32',
      'pxelinux.0',
      'grubx64.efi',
      'shim.efi',
      'shimx64.efi'
    ]
    it { is_expected.to run.with_params(input).and_return(expected_output) }
  end

end
