require 'spec_helper'

describe 'tftpboot::assign_host' do

  let(:title) { 'default' }

  let(:params) { {:model => 'rhel-6-x86_64-base'} }

  it do
    is_expected.to contain_file('/tftpboot/linux-install/pxelinux.cfg/default').with({
      'ensure' => 'link',
      'target' => 'templates/rhel-6-x86_64-base',
      'force'  => true
    })
  end

  context 'with name => DE-AD-BE-EF-00-01 and model => 64_bit_rhel6' do
    let(:title) { 'DE-AD-BE-EF-00-01' }
    let(:params) { {:model => '64_bit_rhel6'} }

    it do
      is_expected.to contain_file('/tftpboot/linux-install/pxelinux.cfg/de-ad-be-ef-00-01').with({
        'ensure' => 'link',
        'target' => 'templates/64_bit_rhel6',
        'force' => true
      })
    end
    it do
      is_expected.to contain_file('/tftpboot/linux-install/pxelinux.cfg/DE-AD-BE-EF-00-01').with({
        'ensure' => 'link',
        'target' => 'templates/64_bit_rhel6',
        'force' => true
      })
    end
  end
end
