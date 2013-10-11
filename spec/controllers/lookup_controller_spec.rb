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
    let(:reg) { stub(voter_id: "600000000", dob: Date.parse('1979-10-24'), vvr_county_or_city: 'NORFOLK CITY') }

    before do
      controller.stub(current_registration: reg)
    end

    describe 'absentee_status_history' do
      it 'should return success', :vcr do
        get :absentee_status_history, voter_id: "600000000"
        expect(response.body).to eq("{\"success\":true,\"items\":[{\"request\":\"Absentee Request\",\"action\":\"Receive\",\"date\":\"Oct 10, 2012\",\"registrar\":\"\",\"notes\":\"\"},{\"request\":\"Absentee Request\",\"action\":\"Approve\",\"date\":\"Oct 10, 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"\"},{\"request\":\"Absentee Request\",\"action\":\"Reject\",\"date\":\"Oct 10, 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"Unsigned\"},{\"request\":\"Absentee Ballot\",\"action\":\"Receive\",\"date\":\"Oct 10, 2012\",\"registrar\":\"\",\"notes\":\"\"},{\"request\":\"Absentee Ballot\",\"action\":\"Approve\",\"date\":\"Oct 10, 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"\"},{\"request\":\"Absentee Ballot\",\"action\":\"Reject\",\"date\":\"Oct 10, 2012\",\"registrar\":\"York County General Registrar Clerk 17\",\"notes\":\"Previous Absentee Ballot\"}]}")
      end

      it 'should return failure' do
        LookupService.should_receive(:absentee_status_history).and_raise(LookupApi::RecordNotFound)
        get :absentee_status_history, voter_id: "600000000"
        expect(response.body).to eq({ success: true, items: [] }.to_json)
      end
    end

    describe 'my_ballot' do
      it 'should return data', :vcr do
        get :my_ballot
        elections = [ { url: ballot_info_path('68c30477-aaf2-46dd-994e-5d3be8a89c9b'), name: "2012 November General #{I18n.t('ballot_info.election')}" } ]
        expect(response.body).to eq({ success: true, items: elections }.to_json)
      end

      it 'should return failure' do
        LookupService.should_receive(:voter_elections).and_raise(LookupApi::RecordNotFound)
        get :my_ballot
        expect(response.body).to eq({ success: true, items: [] }.to_json)
      end
    end
  end

end
