require 'spec_helper'

describe LookupController do

  describe 'registration' do
    it 'should return lookup results' do
      LookupService.should_receive(:registration).with({
        eligible_citizen:             '1',
        eligible_18_next_election:    '1',
        eligible_revoked_felony:      '1',
        eligible_revoked_competence:  '0',
        dob:                          '24/10/1970',
        ssn:                          '123456789',
        dmv_id:                       '123456789' }).and_return({ registered: true, dmv_match: false })

      get :registration, record: {
        eligible_citizen:             '1',
        eligible_18_next_election:    '1',
        eligible_revoked_felony:      '1',
        eligible_revoked_competence:  '0',
        dob:                          '24/10/1970',
        ssn:                          '123456789',
        dmv_id:                       '123456789' }

      response.body.should == { registered: true, dmv_match: false }.to_json
    end
  end

  context 'specific registration' do
    let(:reg) { stub(voter_id: "600000000", dob: 30.years.ago, vvr_county_or_city: 'NORFOLK CITY') }

    before do
      controller.stub(current_registration: reg)
    end

    describe 'absentee_status_history' do
      it 'should return success', :vcr do
        get :absentee_status_history, voter_id: "600000000"
        expect(response.body).to eq("{\"success\":true,\"items\":[{\"request\":\"AbsenteeRequest\",\"action\":\"receive\",\"date\":\"10 Oct 2012\",\"registrar\":\"\",\"notes\":\"\"},{\"request\":\"AbsenteeRequest\",\"action\":\"approve\",\"date\":\"10 Oct 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"\"},{\"request\":\"AbsenteeRequest\",\"action\":\"reject\",\"date\":\"10 Oct 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"rejectUnsigned\"},{\"request\":\"AbsenteeBallot\",\"action\":\"receive\",\"date\":\"10 Oct 2012\",\"registrar\":\"\",\"notes\":\"\"},{\"request\":\"AbsenteeBallot\",\"action\":\"approve\",\"date\":\"10 Oct 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"\"},{\"request\":\"AbsenteeBallot\",\"action\":\"reject\",\"date\":\"10 Oct 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"rejectPreviousVoteAbsentee\"}]}")
      end

      it 'should return failure' do
        LookupService.should_receive(:absentee_status_history).and_raise(LookupApi::RecordNotFound)
        get :absentee_status_history, voter_id: "600000000"
        expect(response.body).to eq({ success: false, message: "Records not found." }.to_json)
      end
    end

    describe 'my_ballot' do
      it 'should return data', :vcr do
        get :my_ballot
        elections = [ { url: my_ballot_election_path('6002FDB4-FC9C-4F36-A418-C0BDFFF2E579'), name: '2013 November General' } ]
        expect(response.body).to eq({ success: true, elections: elections }.to_json)
      end

      it 'should return failure' do
        LookupService.should_receive(:voter_elections).and_raise(LookupApi::RecordNotFound)
        get :my_ballot
        expect(response.body).to eq({ success: false, message: "Records not found." }.to_json)
      end
    end
  end

end
