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
    output = 'ii  vim-tiny                         2:7.4.052-1ubuntu3    amd64                 Vi IMproved - enhanced vi editor - compact version'

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq(['vim-tiny'])
  end

  it 'works with multiple installed packages' do
    # arrange
    output = 'ii  vim-tiny                         2:7.4.052-1ubuntu3    amd64                 Vi IMproved - enhanced vi editor - compact version
    ii  w3m                              0.5.3-15              amd64                 WWW browsable pager with excellent tables/frames support
    '

    # act
    results = @parser.parse output

    # assert
    expect(results).to eq(['vim-tiny', 'w3m'])
  end

  it 'works with rc packages' do
    # arrange
    output = 'rc  rpcbind                          0.2.1-2ubuntu1        amd64                 converts RPC program numbers into universal addresses'

    # act
    results = @parser.parse output

    # assert
    expect(results).to be_empty
  end

  it 'fails if we see a status we dont know' do
    # arrange
    output = 'foo  rpcbind                          0.2.1-2ubuntu1        amd64                 converts RPC program numbers into universal addresses'

    # act
    action = lambda { @parser.parse output }

    # assert
    expect(action).to raise_exception 'Unknown status foo in dpkg -l output'
  end
end