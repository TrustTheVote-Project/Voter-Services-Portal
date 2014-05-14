require 'spec_helper'

describe ExternalPages do

  before do
    ExternalPages.reset_cache
    ExternalPages.stub(get_from_remote: 'about')
  end

  after do
    ExternalPages.reset_cache
  end

  it 'should store page contents' do
    ExternalPages.get_by_name('about')
    expect(ExternalPages).to_not receive(:get_from_remote)
    ExternalPages.get_by_name('about').should == 'about'
  end

  it 'should expire after a while' do
    ExternalPages.stub(expiry_period: 1.second)
    ExternalPages.get_by_name('about')

    sleep 2

    expect(ExternalPages).to receive(:get_from_remote)
    ExternalPages.get_by_name('about')
  end

  it 'should expire on demand' do
    ExternalPages.get_by_name('about')
    ExternalPages.reset_cache
    expect(ExternalPages).to receive(:get_from_remote)
    ExternalPages.get_by_name('about')
  end

end
