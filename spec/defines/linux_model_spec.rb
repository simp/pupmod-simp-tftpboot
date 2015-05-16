require 'spec_helper'

describe 'tftpboot::linux_model' do

  let(:title) { 'rhel_model' }

  let(:params) { {:kernel => 'centos6_x86_64/vmlinuz', :initrd => 'centos6_x86_64/initrd.img',
                  :ks => 'http://localhost/ks/pupclient_x86_64.cfg'} }

  it do
    should contain_file("/tftpboot/linux-install/pxelinux.cfg/templates/rhel_model").with({
      'ensure' => 'present',
      'owner' => 'root',
      'group' => 'nobody',
    })
  end

end
