# Doing a standalone test so need to manually tweak the load path
$: << File.absolute_path(File.join(File.dirname(__FILE__), '../../../libraries'))
require 'rspec/expectations'
require 'dpkg_parser'

describe BswTech::DpkgParser do
  before(:each) do
    @parser = BswTech::DpkgParser.new
  end

  it 'works with no installed packages' do
    # arrange
    output = ''

    # act
    results = @parser.parse output

    # assert
    expect(results).to be_empty
  end

  it 'works with 1 installed package' do
    # arrange
    output = 'vim-tiny ii'

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq(['vim-tiny'])
  end

  it 'works with multiple installed packages' do
    # arrange
    output = 'vim-tiny ii
    w3m ii
    '

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq(['vim-tiny', 'w3m'])
  end

  it 'works with rc packages' do
    # arrange
    output = 'resource-agents ii
    rpcbind rc'

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq ['resource-agents']
  end

  it 'fails if we see a status we dont know' do
    # arrange
    output = 'rpcbind foo'

    # act
    action = lambda { @parser.parse output }

    # assert
    expect(action).to raise_exception "Unknown status 'foo' in dpkg-query -W -f='${binary:Package} ${db:Status-Abbrev}\\n' output"
  end
end