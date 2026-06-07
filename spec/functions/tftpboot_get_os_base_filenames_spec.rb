require 'spec_helper'

describe 'tftpboot::get_os_base_filenames' do
  context 'with an empty hash input' do
    let(:input) { {} }
    let(:expected_output) { [] }

    it { is_expected.to run.with_params(input).and_return(expected_output) }
  end

  context 'with a simple hash input' do
    let(:input) do
      {
        'efi' => {
          'grub' => [
            '/boot/efi/EFI/redhat/grub.efi',
          ],
        },
      }
    end
    let(:expected_output) do
      [
        'grub.efi',
      ]
    end

    it { is_expected.to run.with_params(input).and_return(expected_output) }
  end

  context 'with a complex hash input' do
    let(:input) do
      {
        'bios' => {
          'syslinux-tftpboot' => [
            '/var/lib/tftpboot/menu.c32',
            '/var/lib/tftpboot/pxelinux.0',
          ],
        },
        'efi' => {
          'grub2-efi-x64' => [
            '/boot/efi/EFI/centos/grubx64.efi',
          ],
          'shim-x64' => [
            '/boot/efi/EFI/centos/shim.efi',
            '/boot/efi/EFI/centos/shimx64.efi',
          ],
        },
      }
    end
    let(:expected_output) do
      [
        'menu.c32',
        'pxelinux.0',
        'grubx64.efi',
        'shim.efi',
        'shimx64.efi',
      ]
    end

    it { is_expected.to run.with_params(input).and_return(expected_output) }
  end
end
