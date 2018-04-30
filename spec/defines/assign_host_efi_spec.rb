require 'spec_helper'
require 'securerandom'

describe 'tftpboot::assign_host_efi' do

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

  context 'efi boot grub2' do
    [
      'default',
      'grub.cfg'
    ].each do |default_name|
      context "'#{default_name}' name" do
        let(:title) { default_name }
        let(:params) { { :model => 'rhel-7-x86_64-base', } }

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/grub.cfg').with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'   => true
          })
        end

        it { is_expected.to_not contain_file('/var/lib/tftpboot/linux-install/efi/default') }
        it { is_expected.to_not contain_file('/var/lib/tftpboot/linux-install/efi/DEFAULT') }
        it { is_expected.to_not contain_file('/var/lib/tftpboot/linux-install/efi/GRUB.CFG') }
      end
    end

    context 'uppercase name equals lowercase name' do
      let(:title) { '01020304' }
      let(:params) { { :model => 'rhel-7-x86_64-base', } }

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/grub.cfg-#{title}").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end
    end

    context 'MAC address name' do
      let(:title) { '01-DE-AD-BE-EF-00-01' }
      let(:params) { { :model => 'rhel-7-x86_64-base', } }

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/grub.cfg-#{title.downcase}").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/grub.cfg-#{title.downcase}-").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/grub.cfg-#{title.upcase}").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'  => true
        })
      end

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/grub.cfg-#{title.upcase}-").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end
    end

    [
      SecureRandom.uuid,
      'C000025B',
      'C000025',
      'C00002',
      'C0000',
      'C000',
      'C00',
      'C0',
      'C'
    ].each do |entry|
      context "with name => #{entry}" do
        let(:title) { entry }
        let(:params) { { :model => 'rhel-7-x86_64-base', } }

        it do
          is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/grub.cfg-#{entry.downcase}").with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'   => true
          })
        end

        it do
          is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/grub.cfg-#{entry.upcase}").with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'  => true
          })
        end
      end
    end
  end

  context 'efi boot legacy grub' do
    [
      'default',
      'efidefault',
    ].each do |default_name|
      context "'#{default_name}' name" do
        let(:title) { default_name }
        let(:params) { {
          :model       => 'rhel-6-x86_64-base',
          :legacy_grub => true
        } }

        it do
          is_expected.to contain_file('/var/lib/tftpboot/linux-install/efi/efidefault').with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'   => true
          })
        end

        it { is_expected.to_not contain_file('/var/lib/tftpboot/linux-install/efi/default') }
        it { is_expected.to_not contain_file('/var/lib/tftpboot/linux-install/efi/DEFAULT') }
        it { is_expected.to_not contain_file('/var/lib/tftpboot/linux-install/efi/EFIDEFAULT') }
      end
    end

    context 'uppercase name equals lowercase name' do
      let(:title) { '01020304' }
      let(:params) { {
        :model       => 'rhel-6-x86_64-base',
        :legacy_grub => true
      } }

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/#{title}").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end
    end

    context 'MAC address name' do
      let(:title) { '01-DE-AD-BE-EF-00-01' }
      let(:params) { {
        :model       => 'rhel-6-x86_64-base',
        :legacy_grub => true
      } }

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/#{title.downcase}").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end

      it { is_expected.to_not contain_file("/var/lib/tftpboot/linux-install/efi/#{title.downcase}-") }

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/#{title.upcase}").with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end

      it { is_expected.to_not contain_file("/var/lib/tftpboot/linux-install/efi/#{title.upcase}-") }
    end

    [
      SecureRandom.uuid,
      'C000025B',
      'C000025',
      'C00002',
      'C0000',
      'C000',
      'C00',
      'C0',
      'C'
    ].each do |entry|
      context "with name => #{entry}" do
        let(:title) { entry }
        let(:params) { {
          :model       => 'rhel-6-x86_64-base',
          :legacy_grub => true
        } }

        it do
          is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/#{entry.downcase}").with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'   => true
          })
        end

        it do
          is_expected.to contain_file("/var/lib/tftpboot/linux-install/efi/#{entry.upcase}").with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'  => true
          })
        end
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
        let(:params) { {:model => 'rhel-6-x86_64-base'} }

        it { is_expected.to raise_error(/tftpboot..assign_host_efi '#{title}' invalid. name cannot have whitespace/) }
      end
    end
  end

end
