require 'spec_helper'

describe 'tftpboot::linux_model' do

  let(:title) { 'rhel_model' }

  context 'with default parameters' do
    let(:params) {{
      :kernel => 'centos6_x86_64/vmlinuz',
      :initrd => 'centos6_x86_64/initrd.img',
      :ks => 'http://localhost/ks/pupclient_x86_64.cfg'
    }}

    it do
      is_expected.to contain_file("/tftpboot/linux-install/pxelinux.cfg/templates/rhel_model").with({
        'ensure' => 'present',
        'owner' => 'root',
        'group' => 'nobody',
        'mode' => '0644',
        'content' => <<EOM
default 0
label 0
        kernel centos6_x86_64/vmlinuz
        append initrd=centos6_x86_64/initrd.img ks=http://localhost/ks/pupclient_x86_64.cfg fips=0 
EOM
      })
    end
  end

  context 'with extra set' do
    let(:params) {{
      :kernel => 'centos6_x86_64/vmlinuz',
      :initrd => 'centos6_x86_64/initrd.img',
      :ks => 'http://localhost/ks/pupclient_x86_64.cfg',
      :extra => 'some-extra-args'
    }}

    it do
      is_expected.to contain_file("/tftpboot/linux-install/pxelinux.cfg/templates/rhel_model").with({
        'ensure' => 'present',
        'owner' => 'root',
        'group' => 'nobody',
        'mode' => '0644',
        'content' => <<EOM
default 0
label 0
        kernel centos6_x86_64/vmlinuz
        append initrd=centos6_x86_64/initrd.img ks=http://localhost/ks/pupclient_x86_64.cfg fips=0 some-extra-args
EOM
      })
    end
  end
end
