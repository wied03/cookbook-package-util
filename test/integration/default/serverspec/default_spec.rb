# Encoding: utf-8

require_relative 'spec_helper'

describe package('openssl') do
  expected_version = case os[:family]
                       when 'RedHat7'
                         '1.0.1e-34.el7_0.4'
                       when 'Ubuntu'
                         '1.0.1f-1ubuntu2.5'
                     end

  it { should be_installed.with_version(expected_version) }
end

describe file('/tmp/csv_ran') do
  it { should contain 'csv did run!' }
end

if os[:family] == 'RedHat7'
  describe package('postgresql93-libs') do
    it { should be_installed }
  end

  describe package('python-pip') do
    it { should be_installed }
  end

  describe file('/tmp/notify_me') do
    it { should contain 'i am here' }
  end
end