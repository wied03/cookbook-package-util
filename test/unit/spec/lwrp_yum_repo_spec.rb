require_relative 'spec_helper'

describe 'bsw_package_util::lwrp::yum_repo' do
  include BswTech::ChefSpec::LwrpTestHelper

  before {
    stub_resources
    @shell_out = nil
  }

  after(:each) {
    cleanup
  }

  def cookbook_under_test
    'bsw_package_util'
  end

  def lwrps_full
    ['bsw_package_util_yum_repo', 'yum_repository']
  end

  it 'handles a basic yum attribute' do
    # arrange
    lwrp = <<-EOF
bsw_package_util_yum_repo 'repo1' do
  yum_repo_settings proc {
    baseurl 'http://www.something.com'
  }
end
    EOF
    create_temp_cookbook lwrp

    # act
    temp_lwrp_recipe lwrp

    # assert
    resource = @chef_run.find_resource('yum_repository', 'repo1')
    expect(resource).to_not be_nil
    expect(resource.baseurl).to eq('http://www.something.com')
    expect(resource.description).to eq('Repository for repo1')
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
  end

  it 'handles key URL' do
    # arrange
    lwrp = <<-EOF
    bsw_package_util_yum_repo 'repo1' do
      yum_repo_settings proc {
        gpgkey 'http://www.google.com/ABC'
      }
    end
    EOF
    create_temp_cookbook lwrp

    # act
    temp_lwrp_recipe lwrp

    # assert
    resource = @chef_run.find_resource('yum_repository', 'repo1')
    expect(resource).to_not be_nil
    expect(resource.gpgkey).to eq('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1')
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to create_remote_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1')
  end

  it 'handles key server' do
    # arrange
    fetcher = double('key fetcher')
    allow(BswTech::Hkp::KeyFetcher).to receive(:new).and_return fetcher
    allow(fetcher).to receive(:fetch_key).with('keys.somehost.com','ABC').and_return 'foobar'
    lwrp = <<-EOF
        bsw_package_util_yum_repo 'repo1' do
          yum_repo_settings proc {
            gpgkey [{:key_server => 'keys.somehost.com', :key => 'ABC'}]
          }
        end
    EOF
    create_temp_cookbook lwrp

    # act
    temp_lwrp_recipe lwrp

    # assert
    resource = @chef_run.find_resource('yum_repository', 'repo1')
    expect(resource).to_not be_nil
    expect(resource.gpgkey).to eq('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1')
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1').with_content('foobar')
  end

  it 'handles a direct key' do
    # arrange

    # act

    # assert
    pending 'Write this test'
  end

  it 'handles multiple keys' do
    # arrange

    # act

    # assert
    pending 'Write this test'
  end
end