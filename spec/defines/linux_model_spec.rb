require 'spec_helper'

describe 'tftpboot::linux_model' do
  let(:title) { 'rhel_model' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with default parameters' do
        let(:params) do
          {
            kernel: 'centos6_x86_64/vmlinuz',
            initrd: 'centos6_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64.cfg',
          }
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg/templates/rhel_model').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0644',
            'seltype' => 'tftpdir_t',
            'content' => <<~EOM,
              default 0
              label 0
                      kernel centos6_x86_64/vmlinuz
                      append initrd=centos6_x86_64/initrd.img ks=http://localhost/ks/pupclient_x86_64.cfg fips=0#{' '}
            EOM
          )
        end
      end

      context 'with fips=true' do
        let(:params) do
          {
            kernel: 'centos6_x86_64/vmlinuz',
            initrd: 'centos6_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64.cfg',
            fips: true,
          }
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg/templates/rhel_model').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0644',
            'seltype' => 'tftpdir_t',
            'content' => <<~EOM,
              default 0
              label 0
                      kernel centos6_x86_64/vmlinuz
                      append initrd=centos6_x86_64/initrd.img ks=http://localhost/ks/pupclient_x86_64.cfg fips=1#{' '}
            EOM
          )
        end
      end
      context 'with extra set' do
        let(:params) do
          {
            kernel: 'centos6_x86_64/vmlinuz',
            initrd: 'centos6_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64.cfg',
            extra: 'some-extra-args',
          }
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg/templates/rhel_model').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0644',
            'seltype' => 'tftpdir_t',
            'content' => <<~EOM,
              default 0
              label 0
                      kernel centos6_x86_64/vmlinuz
                      append initrd=centos6_x86_64/initrd.img ks=http://localhost/ks/pupclient_x86_64.cfg fips=0 some-extra-args
            EOM
          )
        end
      end

      context 'invalid name' do
        [
          "\tstarts_with_whitespace",
          'ends_with_whitespace ',
          'name contains whitespace',
        ].each do |invalid_name|
          context "invalid name '#{invalid_name}'" do
            let(:title) { invalid_name }
            let(:params) do
              {
                kernel: 'centos6_x86_64/vmlinuz',
                initrd: 'centos6_x86_64/initrd.img',
                ks: 'http://localhost/ks/pupclient_x86_64.cfg',
              }
            end

            it { is_expected.to raise_error(%r{tftpboot..linux_model '#{title}' invalid. name cannot have whitespace}) }
          end
        end
      end
    end
  end
end
