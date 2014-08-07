require 'csv'
require_relative 'spec_helper'

describe 'bsw_apt_baseline::lwrp:apt_baseline' do
  include BswTech::ChefSpec::LwrpTestHelper

  before {
    stub_resources
    @shell_out = nil
  }

  after(:each) {
    cleanup
  }

  def setup_command(output)
    @shell_out = double()
    allow(Mixlib::ShellOut).to receive(:new)
                               .with("dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev}\\n'")
                               .and_return(@shell_out)
    allow(@shell_out).to receive(:live_stream=)
    allow(@shell_out).to receive(:run_command)
    allow(@shell_out).to receive(:stdout).and_return output
  end

  def cookbook_under_test
    'bsw_apt_baseline'
  end

  def lwrps_under_test
    'csv_to_apt_resources'
  end

  it 'parses the CSV and creates resources appropriately when both are installed' do
    # arrange
    lwrp = <<-EOF
      bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
    setup_command 'bash ii
        openssl ii
    '
    create_temp_cookbook lwrp
    csv_path = File.join cookbook_path, 'files', 'default', 'test1.csv'
    FileUtils.mkdir_p File.dirname(csv_path)
    CSV.open csv_path, 'w' do |csv|
      csv << ['package', 'repository', 'version']
      csv << ['bash', 'amd64/trusty-security', '1.4.2']
      csv << ['openssl', 'amd64/trusty-security', '1.5.2']
    end

    # act
    temp_lwrp_recipe lwrp

    # assert
    expect(@chef_run).to upgrade_apt_package('bash').with_version('1.4.2')
    expect(@chef_run).to upgrade_apt_package('openssl').with_version('1.5.2')
    total_packages = @chef_run.find_resources 'apt_package'
    expect(total_packages.length).to eq(2)
    total_packages.each do |pkg|
      expect(pkg.action).to eq([:upgrade]), 'Need upgrade because we only upgrade something that is already there!'
    end
  end

  it 'parses the CSV and creates resources appropriately when only 1 is installed' do
    # arrange
    lwrp = <<-EOF
        bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
    setup_command 'openssl ii
        '
    create_temp_cookbook lwrp
    csv_path = File.join cookbook_path, 'files', 'default', 'test1.csv'
    FileUtils.mkdir_p File.dirname(csv_path)
    CSV.open csv_path, 'w' do |csv|
      csv << ['package', 'repository', 'version']
      csv << ['bash', 'amd64/trusty-security', '1.4.2']
      csv << ['openssl', 'amd64/trusty-security', '1.5.2']
    end

    # act
    temp_lwrp_recipe lwrp

    # assert
    expect(@chef_run).to_not upgrade_apt_package('bash')
    expect(@chef_run).to upgrade_apt_package('openssl').with_version('1.5.2')
    total_packages = @chef_run.find_resources 'apt_package'
    expect(total_packages.length).to eq(1)
    total_packages.each do |pkg|
      expect(pkg.action).to eq([:upgrade]), 'Need upgrade because we only upgrade something that is already there!'
    end
  end
end