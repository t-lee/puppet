require 'spec_helper'

describe 'hosts::define', type: :define do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      let(:pre_condition) { 'include hosts' }
      let(:title) { 'hosts' }

      context 'when source file' do
        let(:params) do
          {
            config_file_path: '/etc/hosts.2nd',
            config_file_source: 'puppet:///modules/hosts/wheezy/etc/hosts'
          }
        end

        it do
          is_expected.to contain_file('define_hosts').with(
            'ensure'  => 'present',
            'source'  => 'puppet:///modules/hosts/wheezy/etc/hosts',
            'require' => nil
          )
        end
      end

      context 'when content string' do
        let(:params) do
          {
            config_file_path: '/etc/hosts.3rd',
            config_file_string: '# THIS FILE IS MANAGED BY PUPPET'
          }
        end

        it do
          is_expected.to contain_file('define_hosts').with(
            'ensure'  => 'present',
            'content' => %r{THIS FILE IS MANAGED BY PUPPET},
            'require' => nil
          )
        end
      end

      context 'when content template' do
        let(:params) do
          {
            config_file_path: '/etc/hosts.4th',
            config_file_template: 'hosts/wheezy/etc/hosts.erb'
          }
        end

        it do
          is_expected.to contain_file('define_hosts').with(
            'ensure'  => 'present',
            'content' => %r{THIS FILE IS MANAGED BY PUPPET},
            'require' => nil
          )
        end
      end

      context 'when content template (custom)' do
        let(:params) do
          {
            config_file_path: '/etc/hosts.5th',
            config_file_template: 'hosts/wheezy/etc/hosts.erb',
            config_file_options_hash: {
              'key' => 'value'
            }
          }
        end

        it do
          is_expected.to contain_file('define_hosts').with(
            'ensure'  => 'present',
            'content' => %r{THIS FILE IS MANAGED BY PUPPET},
            'require' => nil
          )
        end
      end
    end
  end
end
