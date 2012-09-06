require 'spec_helper'

describe RegistrationForPdf do

  describe 'absentee_election' do
    let(:r) { Registration.new }

    it 'should return election name if chosen' do
      e = Dictionaries::ELECTIONS.first
      r.rab_election = e

      rr = RegistrationForPdf.new(r)
      rr.absentee_election.should == e
    end

    it 'should return custom election name' do
      r.rab_election = 'other'
      r.rab_election_name = 'Custom'
      r.rab_election_date = '05/07/2012'

      rr = RegistrationForPdf.new(r)
      rr.absentee_election.should == 'Custom on 05/07/2012'
    end
  end

end
