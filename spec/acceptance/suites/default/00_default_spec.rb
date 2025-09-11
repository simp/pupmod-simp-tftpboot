require 'spec_helper_acceptance'

test_name 'tftpboot'

describe 'tftpboot' do
  let(:manifest) do
    <<-EOS
      include tftpboot
    EOS
  end

  hosts.each do |host|
    context "on #{host}" do
      context 'with rsync disabled' do
        let(:hieradata) do
          {
            'tftpboot::rsync_enabled' => false,
          }
        end

        it 'works with no errors' do
          set_hieradata_on(host, hieradata)
          apply_manifest_on(host, manifest, catch_failures: true)
        end

        it 'is idempotent' do
          apply_manifest_on(host, manifest, catch_changes: true)
        end
      end
    end
  end
end
