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
    expect(resource.gpgkey).to eq(['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1'])
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to create_remote_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1')
  end

  it 'handles key server' do
    # arrange
    fetcher = double('key fetcher')
    allow(BswTech::Hkp::KeyFetcher).to receive(:new).and_return fetcher
    allow(fetcher).to receive(:fetch_key).with('keys.somehost.com', 'ABC').and_return 'foobar'
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
    expect(resource.gpgkey).to eq(['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1'])
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1').with_content('foobar')
  end

  it 'handles a direct key' do
    # arrange
    lwrp = <<-EOF
        bsw_package_util_yum_repo 'repo1' do
          yum_repo_settings proc {
            gpgkey '-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg'
          }
        end
    EOF
    create_temp_cookbook lwrp

    # act
    temp_lwrp_recipe lwrp

    # assert
    resource = @chef_run.find_resource('yum_repository', 'repo1')
    expect(resource).to_not be_nil
    expect(resource.gpgkey).to eq(['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1'])
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1').with_content('-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg')
  end

  it 'works with a cookbook supplied key' do
    # arrange
    file_path = File.join(cookbook_path, 'files/default/key.pub')
    FileUtils.mkdir_p File.dirname(file_path)
    File.open file_path, 'w' do |file|
      file << '-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg'
    end
    lwrp = <<-EOF
      bsw_package_util_yum_repo 'repo1' do
        yum_repo_settings proc {
          gpgkey [{:file => 'key.pub'}]
        }
      end
    EOF
    create_temp_cookbook lwrp

    # act
    temp_lwrp_recipe lwrp

    # assert
    resource = @chef_run.find_resource('yum_repository', 'repo1')
    expect(resource).to_not be_nil
    expect(resource.gpgkey).to eq(['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1'])
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1').with_content('-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg')
  end

  it 'works with a cookbook supplied key with a different cookbook' do
    # arrange
    other_cookbook_root = File.join(cookbook_path, '../other_cookbook')
    file_path = File.join(other_cookbook_root, 'files/default/key.pub')
    FileUtils.mkdir_p File.dirname(file_path)
    File.open File.join(other_cookbook_root, 'metadata.rb'), 'w' do |file|
      file << "name 'other_cookbook'\n"
      file << "version '0.0.1'\n"
    end
    File.open File.join(cookbook_path, 'metadata.rb'), 'a+' do |file|
      file << "depends 'other_cookbook'"
    end
    File.open file_path, 'w' do |file|
      file << '-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg'
    end
    lwrp = <<-EOF
        bsw_package_util_yum_repo 'repo1' do
          yum_repo_settings proc {
            gpgkey [{:cookbook => 'other_cookbook', :file => 'key.pub'}]
          }
        end
    EOF
    create_temp_cookbook lwrp

    # act
    temp_lwrp_recipe lwrp

    # assert
    resource = @chef_run.find_resource('yum_repository', 'repo1')
    expect(resource).to_not be_nil
    expect(resource.gpgkey).to eq(['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1'])
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1').with_content('-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg')
  end

  it 'handles multiple keys' do
    # arrange
    fetcher = double('key fetcher')
    allow(BswTech::Hkp::KeyFetcher).to receive(:new).and_return fetcher
    allow(fetcher).to receive(:fetch_key).with('keys.somehost.com', 'ABC').and_return 'foobar'
    lwrp = <<-EOF
        bsw_package_util_yum_repo 'repo1' do
          yum_repo_settings proc {
            gpgkey ['-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg',{:key_server => 'keys.somehost.com', :key => 'ABC'}]
          }
        end
    EOF
    create_temp_cookbook lwrp

    # act
    temp_lwrp_recipe lwrp

    # assert
    resource = @chef_run.find_resource('yum_repository', 'repo1')
    expect(resource).to_not be_nil
    expect(resource.gpgkey).to eq(['file:///etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1-1', 'file:///etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1-2'])
    expect(@chef_run).to render_file('/etc/yum.repos.d/repo1.repo')
    expect(@chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1-1').with_content('-----BEGIN PGP PUBLIC KEY BLOCK-----stufffdfgdsdgsg')
    expect(@chef_run).to render_file('/etc/pki/rpm-gpg/RPM-GPG-KEY-REPO1-2').with_content('foobar')
  end
end