# Encoding: utf-8

require_relative 'spec_helper'

describe package('openssl') do
  expected_version = case os[:family]
                       when 'RedHat'
                         '1.0.1e-34.el7_0.4'
                       when 'Ubuntu'
                         '1.0.1f-1ubuntu2.5'
                     end

  it { should be_installed.with_version(expected_version) }
end