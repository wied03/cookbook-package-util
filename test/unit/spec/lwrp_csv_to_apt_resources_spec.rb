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
                               .with("dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev} ${Version}\\n'")
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

  it 'parses the CSV and loads the packages in the resource' do
    # arrange
    lwrp = <<-EOF
          bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
    setup_command 'bash ii  1.4.2
            openssl ii  1.5.2
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
    resource = @chef_run.find_resource('bsw_apt_baseline_csv_to_apt_resources', 'test1.csv')
    expect(resource.packages).to eq([
                                        {"package" => "bash", "repository" => "amd64/trusty-security", "version" => "1.4.2"},
                                        {"package" => "openssl", "repository" => "amd64/trusty-security", "version" => "1.5.2"}
                                    ])
  end

  it 'does not upgrade if both packages are already installed' do
    # arrange
    lwrp = <<-EOF
        bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
    setup_command 'bash ii  1.4.2
          openssl ii  1.5.2
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
    expect(@chef_run).to_not run_execute('sudo apt-get -q -y upgrade bash=1.4.2 openssl=1.5.2')
  end

  it 'upgrades 1 of the packages if its behind' do
    # arrange
    lwrp = <<-EOF
        bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
    setup_command 'bash ii  1.4.2
          openssl ii  1.4.0
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
    expect(@chef_run).to run_execute('sudo apt-get -q -y upgrade openssl=1.5.2')
  end

  it 'upgrades both of the packages if they are both behind' do
    # arrange
    lwrp = <<-EOF
          bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
    setup_command 'bash ii  1.4.0
            openssl ii  1.4.0
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
    expect(@chef_run).to run_execute('sudo apt-get -q -y upgrade bash=1.4.2 openssl=1.5.2')
  end

  it 'upgrades appropriately when only 1 is installed' do
    # arrange
    lwrp = <<-EOF
        bsw_apt_baseline_csv_to_apt_resources 'test1.csv'
    EOF
    setup_command 'openssl ii  1.4.0
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
    expect(@chef_run).to run_execute('sudo apt-get -q -y upgrade openssl=1.5.2')
  end
end