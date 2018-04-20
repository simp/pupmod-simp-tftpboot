require 'spec_helper'
require 'securerandom'

describe 'tftpboot::assign_host' do

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

  context 'valid parameters' do
    context "'default' name" do
      let(:title) { 'default' }
      let(:params) { {:model => 'rhel-6-x86_64-base'} }

      it do
        is_expected.to contain_file('/var/lib/tftpboot/linux-install/pxelinux.cfg/default').with({
          'ensure'  => 'link',
          'owner'   => 'root',
          'group'   => 'nobody',
          'seltype' => 'tftpdir_t',
          'target'  => "templates/#{params[:model]}",
          'force'   => true
        })
      end

      it { is_expected.to_not contain_file('/var/lib/tftpboot/linux-install/pxeclinux.cfg/DEFAULT') }
    end

    context 'uppercase name equals lowercase name' do
      let(:title) { '01020304' }
      let(:params) { {:model => 'rhel-6-x86_64-base'} }

      it do
        is_expected.to contain_file("/var/lib/tftpboot/linux-install/pxelinux.cfg/#{title}").with({
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
      '01-DE-AD-BE-EF-00-01',
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
        let(:params) { {:model => '64_bit_rhel6'} }

        it do
          is_expected.to contain_file("/var/lib/tftpboot/linux-install/pxelinux.cfg/#{entry.downcase}").with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'   => true
          })
        end

        it do
          is_expected.to contain_file("/var/lib/tftpboot/linux-install/pxelinux.cfg/#{entry.upcase}").with({
            'ensure'  => 'link',
            'owner'   => 'root',
            'group'   => 'nobody',
            'seltype' => 'tftpdir_t',
            'target'  => "templates/#{params[:model]}",
            'force'   => true
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

        it { is_expected.to raise_error(/tftpboot..assign_host '#{title}' invalid. name cannot have whitespace/) }
      end
    end
  end

end
