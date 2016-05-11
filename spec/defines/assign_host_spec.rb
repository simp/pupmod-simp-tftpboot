require 'spec_helper'

describe 'tftpboot::assign_host' do

  let(:title) { 'default' }

  let(:params) { {:model => 'rhel-6-x86_64-base'} }

  it do
    is_expected.to contain_file('/tftpboot/linux-install/pxelinux.cfg/default').with({
      'ensure' => 'link',
      'target' => "templates/#{params[:model]}",
      'force'  => true
    })
  end

  require 'securerandom'

  [
    SecureRandom.uuid,
    '01-DE-AD-BE-EF-00-01',
    'C000025B'
  ].each do |entry|
    context 'with name => 01-DE-AD-BE-EF-00-01 and model => 64_bit_rhel6' do
      let(:title) { entry }
      let(:params) { {:model => '64_bit_rhel6'} }
  
      it do
        is_expected.to contain_file("/tftpboot/linux-install/pxelinux.cfg/#{entry.downcase}").with({
          'ensure' => 'link',
          'target' => "templates/#{params[:model]}",
          'force' => true
        })
  
        is_expected.to contain_file("/tftpboot/linux-install/pxelinux.cfg/#{entry.upcase}").with({
          'ensure' => 'link',
          'target' => "templates/#{params[:model]}",
          'force' => true
        })
      end
    end
  end
end
