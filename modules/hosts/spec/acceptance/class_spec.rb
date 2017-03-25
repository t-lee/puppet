require 'spec_helper_acceptance'

case fact('osfamily')
when 'Debian'
  config_file_path = '/etc/hosts'
end

describe 'hosts', if: SUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  it 'is_expected.to work with no errors' do
    pp = <<-EOS
      class { 'hosts': }
    EOS

    apply_manifest(pp, catch_failures: true)
    apply_manifest(pp, catch_changes: true)
  end

  #  describe 'hosts::install' do
  #    context 'defaults' do
  #      it 'is_expected.to work with no errors' do
  #        pp = <<-EOS
  #          class { 'hosts': }
  #        EOS
  #
  #        apply_manifest(pp, :catch_failures => true)
  #      end
  #
  #      describe package(package_name) do
  #        it { is_expected.to be_installed }
  #      end
  #    end
  #
  #    context 'when package latest' do
  #      it 'is_expected.to work with no errors' do
  #        pp = <<-EOS
  #          class { 'hosts':
  #            package_ensure => 'latest',
  #          }
  #        EOS
  #
  #        apply_manifest(pp, :catch_failures => true)
  #      end
  #
  #      describe package(package_name) do
  #        it { is_expected.to be_installed }
  #      end
  #    end
  #
  #    context 'when package absent' do
  #      it 'is_expected.to work with no errors' do
  #        pp = <<-EOS
  #          class { 'hosts':
  #            package_ensure => 'absent',
  #          }
  #        EOS
  #
  #        apply_manifest(pp, :catch_failures => true)
  #      end
  #
  #      describe package(package_name) do
  #        it { is_expected.not_to be_installed }
  #      end
  #      describe file(config_file_path) do
  #        it { is_expected.to be_file }
  #      end
  #    end
  #
  #    context 'when package purged' do
  #      it 'is_expected.to work with no errors' do
  #        pp = <<-EOS
  #          class { 'hosts':
  #            package_ensure => 'purged',
  #          }
  #        EOS
  #
  #        apply_manifest(pp, :catch_failures => true)
  #      end
  #
  #      describe package(package_name) do
  #        it { is_expected.not_to be_installed }
  #      end
  #      describe file(config_file_path) do
  #        it { is_expected.not_to be_file }
  #      end
  #    end
  #  end

  describe 'hosts::config' do
    context 'defaults' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'hosts': }
        EOS

        apply_manifest(pp, catch_failures: true)
      end

      describe file(config_file_path) do
        it { is_expected.to be_file }
      end
    end

    context 'when content template' do
      it 'is_expected.to work with no errors' do
        pp = <<-EOS
          class { 'hosts':
            config_file_template => "hosts/#{fact('lsbdistcodename')}/#{config_file_path}.erb",
          }
        EOS

        apply_manifest(pp, catch_failures: true)
      end

      describe file(config_file_path) do
        it { is_expected.to be_file }
        it { is_expected.to contain 'THIS FILE IS MANAGED BY PUPPET' }
      end
    end
  end
end
