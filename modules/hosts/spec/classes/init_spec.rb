require 'spec_helper'

describe 'hosts', type: :class do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      it { is_expected.to compile.with_all_deps }
      it { is_expected.to contain_anchor('hosts::begin') }
      it { is_expected.to contain_class('hosts::params') }
      it { is_expected.to contain_class('hosts::install') }
      it { is_expected.to contain_class('hosts::config') }
      it { is_expected.to contain_anchor('hosts::end') }

      # describe 'hosts::install' do
      #   context 'defaults' do
      #     it do
      #       is_expected.to contain_package('hosts').with(
      #         'ensure' => 'present',
      #       )
      #     end
      #   end

      #   context 'when package latest' do
      #     let(:params) {{
      #       :package_ensure => 'latest',
      #     }}

      #     it do
      #       is_expected.to contain_package('hosts').with(
      #         'ensure' => 'latest',
      #       )
      #     end
      #   end

      #   context 'when package absent' do
      #     let(:params) {{
      #       :package_ensure => 'absent',
      #     }}

      #     it do
      #       is_expected.to contain_package('hosts').with(
      #         'ensure' => 'absent',
      #       )
      #     end
      #     it do
      #       is_expected.to contain_file('hosts.conf').with(
      #         'ensure'  => 'present',
      #         'require' => nil,
      #       )
      #     end
      #   end

      #   context 'when package purged' do
      #     let(:params) {{
      #       :package_ensure => 'purged',
      #     }}

      #     it do
      #       is_expected.to contain_package('hosts').with(
      #         'ensure' => 'purged',
      #       )
      #     end
      #     it do
      #       is_expected.to contain_file('hosts.conf').with(
      #         'ensure'  => 'absent',
      #         'require' => nil,
      #       )
      #     end
      #   end
      # end

      describe 'hosts::config' do
        context 'defaults' do
          it do
            is_expected.to contain_file('hosts.conf').with(
              'ensure'  => 'present',
              'require' => nil
            )
          end
        end

        context 'when source dir' do
          let(:params) do
            {
              config_dir_source: 'puppet:///modules/hosts/wheezy/etc/hosts'
            }
          end

          it do
            is_expected.to contain_file('hosts.dir').with(
              'ensure'  => 'directory',
              'force'   => false,
              'purge'   => false,
              'recurse' => true,
              'source'  => 'puppet:///modules/hosts/wheezy/etc/hosts',
              'require' => nil
            )
          end
        end

        context 'when source dir purged' do
          let(:params) do
            {
              config_dir_purge: true,
              config_dir_source: 'puppet:///modules/hosts/wheezy/etc/hosts'
            }
          end

          it do
            is_expected.to contain_file('hosts.dir').with(
              'ensure'  => 'directory',
              'force'   => true,
              'purge'   => true,
              'recurse' => true,
              'source'  => 'puppet:///modules/hosts/wheezy/etc/hosts',
              'require' => nil
            )
          end
        end

        context 'when source file' do
          let(:params) do
            {
              config_file_source: 'puppet:///modules/hosts/wheezy/etc/hosts'
            }
          end

          it do
            is_expected.to contain_file('hosts.conf').with(
              'ensure'  => 'present',
              'source'  => 'puppet:///modules/hosts/wheezy/etc/hosts',
              'require' => nil
            )
          end
        end

        context 'when content string' do
          let(:params) do
            {
              config_file_string: '# THIS FILE IS MANAGED BY PUPPET'
            }
          end

          it do
            is_expected.to contain_file('hosts.conf').with(
              'ensure'  => 'present',
              'content' => %r{THIS FILE IS MANAGED BY PUPPET},
              'require' => nil
            )
          end
        end

        context 'when content template' do
          let(:params) do
            {
              config_file_template: 'hosts/wheezy/etc/hosts.erb'
            }
          end

          it do
            is_expected.to contain_file('hosts.conf').with(
              'ensure'  => 'present',
              'content' => %r{THIS FILE IS MANAGED BY PUPPET},
              'require' => nil
            )
          end
        end

        context 'when content template (custom)' do
          let(:params) do
            {
              config_file_template: 'hosts/wheezy/etc/hosts.erb',
              config_file_options_hash: {
                'key' => 'value'
              }
            }
          end

          it do
            is_expected.to contain_file('hosts.conf').with(
              'ensure'  => 'present',
              'content' => %r{THIS FILE IS MANAGED BY PUPPET},
              'require' => nil
            )
          end
        end
      end
    end
  end
end
