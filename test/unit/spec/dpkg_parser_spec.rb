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
    output = 'vim-tiny ii  1.4.0'

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq([{:name => 'vim-tiny', :version => '1.4.0'}])
  end

  it 'works with multiple installed packages' do
    # arrange
    output = 'vim-tiny ii  1.4.0
    w3m ii  1.3.0
    '

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq([{:name => 'vim-tiny', :version => '1.4.0'}, {:name => 'w3m', :version => '1.3.0'}])
  end

  it 'works with rc packages' do
    # arrange
    output = 'resource-agents ii  3.5.0f
    rpcbind rc  2.3.0'

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq([{:name => 'resource-agents', :version => '3.5.0f'}])
  end

  it 'fails if we see a status we dont know' do
    # arrange
    output = 'rpcbind foo  2.4.0'

    # act
    action = lambda { @parser.parse output }

    # assert
    expect(action).to raise_exception "Unknown status 'foo' in dpkg-query output"
  end
end