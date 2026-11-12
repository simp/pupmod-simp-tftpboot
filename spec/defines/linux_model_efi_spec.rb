require 'spec_helper'

describe 'tftpboot::linux_model_efi' do
  let(:title) { 'rhel_model' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) do
        os_facts
      end

      context 'with default parameters' do
        let(:params) do
          {
            kernel: 'rocky9_x86_64/vmlinuz',
            initrd: 'rocky9_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64_efi.cfg',
          }
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates/rhel_model').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0644',
            'seltype' => 'tftpdir_t',
            'content' => <<~EOM,
              set default="0"
              set timeout=1

              menuentry 'rhel_model' {
                      linuxefi /linux-install/rocky9_x86_64/vmlinuz inst.ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=0#{' '}
                      initrdefi /linux-install/rocky9_x86_64/initrd.img
              }
            EOM
          )
        end
      end

      context 'with fips=true' do
        let(:params) do
          {
            kernel: 'rocky9_x86_64/vmlinuz',
            initrd: 'rocky9_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64_efi.cfg',
            fips: true,
          }
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates/rhel_model').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0644',
            'seltype' => 'tftpdir_t',
            'content' => <<~EOM,
              set default="0"
              set timeout=1

              menuentry 'rhel_model' {
                      linuxefi /linux-install/rocky9_x86_64/vmlinuz inst.ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=1#{' '}
                      initrdefi /linux-install/rocky9_x86_64/initrd.img
              }
            EOM
          )
        end
      end

      context 'with simp_options::fips set' do
        let(:facts) { os_facts.merge(custom_hiera: 'simp_options_fips') }
        let(:params) do
          {
            kernel: 'rocky9_x86_64/vmlinuz',
            initrd: 'rocky9_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64_efi.cfg',
          }
        end

        it { is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates/rhel_model').with_content(%r{ inst\.ks=http://localhost/ks/pupclient_x86_64_efi\.cfg fips=1 }) }

        context 'with fips=false' do
          let(:params) { super().merge(fips: false) }

          it { is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates/rhel_model').with_content(%r{ fips=0 }) }
        end
      end

      context 'with legacy installer options in extra' do
        let(:params) do
          {
            kernel: 'rocky9_x86_64/vmlinuz',
            initrd: 'rocky9_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64_efi.cfg',
            extra: 'ksdevice=bootif repo=http://localhost/repo',
          }
        end

        it 'warns about the un-prefixed options' do
          allow(Puppet::Util::Log).to receive(:log_func).and_call_original
          expect(Puppet::Util::Log).to receive(:log_func).with(anything, :warning, [%r{tftpboot::linux_model_efi 'rhel_model': `extra` contains un-prefixed installer options}])
          is_expected.to compile.with_all_deps
        end

        context 'with inst.-prefixed options' do
          let(:params) { super().merge(extra: 'inst.repo=http://localhost/repo ip=dhcp') }

          it 'does not warn' do
            allow(Puppet::Util::Log).to receive(:log_func).and_call_original
            expect(Puppet::Util::Log).not_to receive(:log_func).with(anything, :warning, anything)
            is_expected.to compile.with_all_deps
          end
        end
      end

      context 'with extra set' do
        let(:params) do
          {
            kernel: 'rocky9_x86_64/vmlinuz',
            initrd: 'rocky9_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64_efi.cfg',
            extra: 'some-extra-args',
          }
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates/rhel_model').with(
            'ensure'  => 'present',
            'owner'   => 'root',
            'group'   => 'nobody',
            'mode'    => '0644',
            'seltype' => 'tftpdir_t',
            'content' => <<~EOM,
              set default="0"
              set timeout=1

              menuentry 'rhel_model' {
                      linuxefi /linux-install/rocky9_x86_64/vmlinuz inst.ks=http://localhost/ks/pupclient_x86_64_efi.cfg fips=0 some-extra-args
                      initrdefi /linux-install/rocky9_x86_64/initrd.img
              }
            EOM
          )
        end
      end

      context 'with ensure=absent' do
        let(:params) do
          {
            kernel: 'rocky9_x86_64/vmlinuz',
            initrd: 'rocky9_x86_64/initrd.img',
            ks: 'http://localhost/ks/pupclient_x86_64_efi.cfg',
            ensure: 'absent',
          }
        end

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/templates/rhel_model').with_ensure('absent')
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
                kernel: 'rocky9_x86_64/vmlinuz',
                initrd: 'rocky9_x86_64/initrd.img',
                ks: 'http://localhost/ks/pupclient_x86_64_efi.cfg',
              }
            end

            it { is_expected.to raise_error(%r{tftpboot..linux_model_efi '#{title}' invalid. name cannot have whitespace}) }
          end
        end
      end
    end
  end
end
