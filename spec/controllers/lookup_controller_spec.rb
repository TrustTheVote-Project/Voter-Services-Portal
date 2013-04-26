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

end
