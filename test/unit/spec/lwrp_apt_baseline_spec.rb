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
    'apt_baseline'
  end

  it 'parses the CSV and creates resources appropriately' do
    # arrange

    # act

    # assert
    pending 'Write this test'
  end
end