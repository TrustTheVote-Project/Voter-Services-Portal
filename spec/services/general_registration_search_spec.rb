require 'spec_helper'

describe GeneralRegistrationSearch do

  describe 'perform' do
    subject { GeneralRegistrationSearch.perform(query, config)}
    let(:query) { double }
    let(:config) { { 'url' => 'url' } }
    let(:adapter_mock) { double( to_registration: :registration) }

    it 'passes result to VriAdapter' do
      # how to mock URI('url') ?
      expect(LookupApi).to receive(:parse_uri_without_timeout) # can't mock {yield :response} to get a side effect
      expect(VriAdapter).to receive(:new).with(anything).and_return(adapter_mock)
      expect(subject).to be_eql :registration
    end
  end
end
