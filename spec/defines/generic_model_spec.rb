require 'spec_helper'

describe 'tftpboot::generic_model' do

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

    let(:params) { {:content => 'foobarbaz'} }

    it do
      is_expected.to contain_file('/var/lib/tftpboot/pxe-linux/templates/rhel_model').with({
        'ensure'  => 'present',
        'owner'   => 'root',
        'group'   => 'nobody',
        'seltype' => 'tftpdir_t',
        'content' => 'foobarbaz'
      })
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
        let(:params) { {:content => 'foobarbaz'} }

        it { is_expected.to raise_error(/tftpboot..generic_model '#{title}' invalid. name cannot have whitespace/) }
      end
    end
  end
end
