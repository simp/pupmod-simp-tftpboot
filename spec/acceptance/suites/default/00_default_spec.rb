require 'spec_helper_acceptance'

test_name 'tftpboot'

describe 'tftpboot' do
  let(:manifest) {
    <<-EOS
      include tftpboot
    EOS
  }

  hosts.each do |host|
    context "on #{host}" do
      context 'with rsync disabled' do
        let(:hieradata) {{
          'tftpboot::rsync_enabled' => false
        }}

        it 'should work with no errors' do
          set_hieradata_on(host, hieradata)
          apply_manifest_on(host, manifest, :catch_failures => true)
        end

        it 'should be idempotent' do
          apply_manifest_on(host, manifest, :catch_changes => true)
        end
      end
    end
  end
end
