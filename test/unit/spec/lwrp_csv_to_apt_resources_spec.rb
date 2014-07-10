require 'csv'
require_relative 'spec_helper'

describe 'bsw_apt_baseline::lwrp:apt_baseline' do
  include BswTech::ChefSpec::LwrpTestHelper

  before {
    stub_resources
  }

  after(:each) {
    cleanup
  }

  def cookbook_under_test
    'bsw_apt_baseline'
  end

  def lwrps_under_test
    'csv_to_apt_resources'
  end

  it 'parses the CSV and creates resources appropriately' do
    # arrange
    lwrp = <<-EOF
      bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
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
    expect(@chef_run).to install_apt_package('bash').with_version('1.4.2')
    expect(@chef_run).to install_apt_package('openssl').with_version('1.5.2')
    total_packages = @chef_run.find_resources 'apt_package'
    expect(total_packages.length).to eq(2)
  end
end