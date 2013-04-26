require 'spec_helper'

describe ActiveForm do

  let(:session)   { {} }
  let(:new_reg)   { Registration.new(vvr_county_or_city: 'NORFOLK CITY', residence: 'in') }
  let(:existing)  { Registration.new(vvr_county_or_city: 'ALEXANDRIA COUNTY', voter_id: '600000000', residence: 'outside') }

  it { should validate_presence_of :form }

  it 'should mark the beginning of session' do
    ActiveForm.mark!(session, new_reg)

    af = ActiveForm.last
    af.form.should          == 'VoterRegistration'
    af.voter_id.should      be_blank
    af.jurisdiction.should  == 'NORFOLK CITY'

    session[:afid].should == af.id
  end

  it 'should update session with new action' do
    ActiveForm.mark!(session, new_reg)
    ActiveForm.mark!(session, existing)

    ActiveForm.count.should == 1
    af = ActiveForm.last
    af.form.should          == 'VoterRecordUpdateAbsenteeRequest'
    af.voter_id.should      == '600000000'
    af.jurisdiction.should  == 'ALEXANDRIA COUNTY'

    session[:afid].should == af.id
  end

  it 'should raise an error if there is no active form' do
    session[:afid] = 1
    lambda { ActiveForm.find_for_session!(session) }.should raise_error ActiveForm::Expired
  end

  it 'should unmark the beginning of session upon completion' do
    af = ActiveForm.mark!(session, new_reg)
    af.unmark!

    ActiveForm.count.should == 0
    session.should_not include :afid
  end

  describe 'sweeping' do
    let!(:expired) { FactoryGirl.create(:active_form, form: 'F1', voter_id: '222222222', jurisdiction: 'NORF', updated_at: 1.day.ago) }
    let!(:fresh)   { FactoryGirl.create(:active_form, form: 'F2', voter_id: '111111111') }

    before { ActiveForm.sweep }

    it 'should remove discarded sessions' do
      r = LogRecord.last
      r.action.should       == 'discard'
      r.form.should         == expired.form
      r.voter_id.should     == expired.voter_id
      r.jurisdiction.should == expired.jurisdiction
    end

    it 'should log discarded sessions' do
      ActiveForm.all.should_not include expired
    end
  end

end
