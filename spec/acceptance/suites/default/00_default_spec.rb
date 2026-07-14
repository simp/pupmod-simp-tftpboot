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
      # Exercise noop from a clean (uninstalled) state: on a fresh node the Sicura
      # console previews the module with `puppet apply --noop`, which must not error
      # even though nothing tftpboot manages exists yet. Real idempotence is covered
      # by the applies below. A post-convergence noop check is deliberately omitted:
      # `puppet apply --noop --detailed-exitcodes` always exits 0, so it could never
      # fail and would test nothing.
      context 'in noop mode from a clean state' do
        # Setup, not an assertion: as before(:context) a failure errors this context
        # rather than aborting the whole suite under .rspec's --fail-fast. `puppet
        # resource` exits 0 whether it removes the package or finds it already absent
        # (no --detailed-exitcodes), so no acceptable_exit_codes override is needed.
        before(:context) do
          # tftpboot's rsync integration probes an rsync daemon that a fresh node
          # has no reason to be running (the module's own acceptance tests only
          # ever apply with rsync disabled); that probe runs even under noop, so
          # preview the package/config path with rsync disabled here too.
          set_hieradata_on(host, { 'tftpboot::rsync_enabled' => false })
          on(host, 'puppet resource package tftp-server ensure=absent')
        end

        it 'applies without errors in noop mode' do
          apply_manifest_on(host, manifest, catch_failures: true, noop: true)
        end
      end

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
