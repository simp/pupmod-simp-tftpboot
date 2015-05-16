require 'spec_helper'

describe 'tftpboot::generic_model' do

  let(:title) { 'rhel_model' }

  let(:params) { {:content => 'foobarbaz'} }

  it do
    should contain_file('/tftpboot/pxe-linux/templates/rhel_model').with({
      'ensure' => 'present',
      'owner'  => 'root',
      'group'  => 'nobody',
      'content' => 'foobarbaz'
    })
  end
end
