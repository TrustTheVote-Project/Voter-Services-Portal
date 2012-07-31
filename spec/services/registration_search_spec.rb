require 'spec_helper'

describe RegistrationSearch do

  describe 'by known voter id' do
    let(:q) { stub(voter_id: 600000000) }
    subject do
      VCR.use_cassette('voter_by_known_id') do
        RegistrationSearch.perform(q)
      end
    end

    it { should be_kind_of Registration }
    its(:first_name)  { should == "BRANDY" }
    its(:last_name)   { should == "FRYE" }
    its(:middle_name) { should == "RAY" }
  end

end
