require 'spec_helper'

describe 'tftpboot::linux_model_efi' do

  let(:title) { 'rhel_model' }

  # set the bare minimum facts needed for tftpboot class included
  # by tftpboot::linux_model
  let(:facts) {{
    'os'                        => {
      'name' => 'RedHat'
    },
    'operatingsystem'           => 'RedHat',
    'operatingsystemmajrelease' => '7',
    'osfamily'                  => 'RedHat',
    'kernel'                    => 'Linux'
  }}

  context 'with default parameters' do

    let(:params) {{
      :kernel => 'centos6_x86_64/vmlinuz',
      :initrd => 'centos6_x86_64/initrd.img',
      :ks     => 'http://localhost/ks/pupclient_x86_64_efi.cfg'
    }}

    it do
      is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'nobody',
        'mode'    => '0644',
        'seltype' => 'tftpdir_t',
        'content' => <<EOM
set default="0"
set timeout=1

menuentry 'rhel_model' {
        linuxefi /linux-install/centos6_x86_64/vmlinuz ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=0 
        initrdefi /linux-install/centos6_x86_64/initrd.img
}
EOM
      })
    end
  end

  context 'with fips=true' do
    let(:params) {{
      :kernel => 'centos6_x86_64/vmlinuz',
      :initrd => 'centos6_x86_64/initrd.img',
      :ks     => 'http://localhost/ks/pupclient_x86_64_efi.cfg',
      :fips   => true
    }}

    it do
      is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'nobody',
        'mode'    => '0644',
        'seltype' => 'tftpdir_t',
        'content' => <<EOM
set default="0"
set timeout=1

menuentry 'rhel_model' {
        linuxefi /linux-install/centos6_x86_64/vmlinuz ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=1 
        initrdefi /linux-install/centos6_x86_64/initrd.img
}
EOM
      })
    end
  end

  context 'with extra set' do
    let(:params) {{
      :kernel => 'centos6_x86_64/vmlinuz',
      :initrd => 'centos6_x86_64/initrd.img',
      :ks     => 'http://localhost/ks/pupclient_x86_64_efi.cfg',
      :extra  => 'some-extra-args'
    }}

    it do
      is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'nobody',
        'mode'    => '0644',
        'seltype' => 'tftpdir_t',
        'content' => <<EOM
set default="0"
set timeout=1

menuentry 'rhel_model' {
        linuxefi /linux-install/centos6_x86_64/vmlinuz ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=0 some-extra-args
        initrdefi /linux-install/centos6_x86_64/initrd.img
}
EOM
      })
    end
  end

  context 'with ensure=absent' do
    let(:params) {{
      :kernel => 'centos6_x86_64/vmlinuz',
      :initrd => 'centos6_x86_64/initrd.img',
      :ks     => 'http://localhost/ks/pupclient_x86_64_efi.cfg',
      :ensure => 'absent'
    }}

    it do
      is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with_ensure('absent')
    end
  end


  context 'with legacy_grub=true ' do
    context 'with all other parameters default' do
      let(:params) {{
        :kernel      => 'centos6_x86_64/vmlinuz',
        :initrd      => 'centos6_x86_64/initrd.img',
        :ks          => 'http://localhost/ks/pupclient_x86_64_efi.cfg',
        :legacy_grub => true
      }}

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'nobody',
          'mode'    => '0644',
          'seltype' => 'tftpdir_t',
          'content' => <<EOM
default=0
timeout=1
hiddenmenu

title 'rhel_model'
        root (nd)
        kernel /../centos6_x86_64/vmlinuz ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=0 
        initrd /../centos6_x86_64/initrd.img
EOM
        })
      end
    end

    context 'with fips=true' do
      let(:params) {{
        :kernel      => 'centos6_x86_64/vmlinuz',
        :initrd      => 'centos6_x86_64/initrd.img',
        :ks          => 'http://localhost/ks/pupclient_x86_64_efi.cfg',
        :fips        => true,
        :legacy_grub => true
      }}

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'nobody',
          'mode'    => '0644',
          'seltype' => 'tftpdir_t',
          'content' => <<EOM
default=0
timeout=1
hiddenmenu

title 'rhel_model'
        root (nd)
        kernel /../centos6_x86_64/vmlinuz ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=1 
        initrd /../centos6_x86_64/initrd.img
EOM
        })
      end
    end

    context 'with extra set' do
      let(:params) {{
        :kernel      => 'centos6_x86_64/vmlinuz',
        :initrd      => 'centos6_x86_64/initrd.img',
        :ks          => 'http://localhost/ks/pupclient_x86_64_efi.cfg',
        :extra       => 'some-extra-args',
        :legacy_grub => true
      }}

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with({
          'ensure'  => 'present',
          'owner'   => 'root',
          'group'   => 'nobody',
          'mode'    => '0644',
          'seltype' => 'tftpdir_t',
          'content' => <<EOM
default=0
timeout=1
hiddenmenu

title 'rhel_model'
        root (nd)
        kernel /../centos6_x86_64/vmlinuz ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=0 some-extra-args
        initrd /../centos6_x86_64/initrd.img
EOM
        })
      end
    end

    context 'with ensure=absent' do
      let(:params) {{
        :kernel      => 'centos6_x86_64/vmlinuz',
        :initrd      => 'centos6_x86_64/initrd.img',
        :ks          => 'http://localhost/ks/pupclient_x86_64_efi.cfg',
        :ensure      => 'absent',
        :legacy_grub => true
      }}

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/templates/rhel_model").with_ensure('absent')
      end
    end

  end

  context 'invalid name' do
    [
      "\tstarts_with_whitespace",
      'ends_with_whitespace ',
      'name contains whitespace'
    ].each do |invalid_name|
      context "invalid name '#{invalid_name}'" do
        let(:title) { invalid_name }
        let(:params) {{
          :kernel => 'centos6_x86_64/vmlinuz',
          :initrd => 'centos6_x86_64/initrd.img',
          :ks     => 'http://localhost/ks/pupclient_x86_64_efi.cfg'
        }}

        it { is_expected.to raise_error(/tftpboot..linux_model_efi '#{title}' invalid. name cannot have whitespace/) }
      end
    end
  end
end
