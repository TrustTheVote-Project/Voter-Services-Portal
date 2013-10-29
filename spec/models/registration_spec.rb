require 'spec_helper'

describe Registration do

  it 'should cleanup ssn' do
    FactoryGirl.create(:registration, ssn: '123-45-6789').ssn.should == '123456789'
  end

  describe 'full_name' do
    specify { FactoryGirl.build(:registration, first_name: 'Wanda', middle_name: 'Hunt', last_name: 'Phelps', suffix: 'III').full_name.should == 'Wanda Hunt Phelps III' }
    specify { FactoryGirl.build(:registration, first_name: 'John', last_name: 'Smith').full_name.should == 'John Smith' }
  end

  describe 'saving previous data' do
    let(:reg) { FactoryGirl.create(:registration) }

    specify { reg.previous_data.should be_nil }
    it "should save previous value on update" do
      previous_first_name = reg.first_name
      reg.update_attributes(first_name: 'Mike')
      reg.reload
      reg.previous_data[:first_name].should == previous_first_name
    end
  end

  describe 'init_update_to' do
    let(:r) { FactoryGirl.create(:registration, :domestic_absentee) }

    it 'should handle no kind (no status change)' do
      r.init_update_to(nil)
      r.should be_absentee
      r.should be_residential
    end

    it 'should handle domestic_absentee' do
      r.init_update_to('domestic_absentee')
      r.should be_absentee
      r.should be_residential
    end

    it 'should handle residential_voter' do
      r.init_update_to('residential_voter')
      r.should_not be_absentee
      r.should be_residential
    end

    it 'should handle overseas' do
      r.init_update_to('overseas')
      r.should be_absentee
      r.should_not be_residential
    end
  end

  describe 'voter_type' do
    it 'should return nil for when voter_id is not present' do
      r = Registration.new
      r.voter_type.should be_nil
    end

    it 'should return overseas absentee' do
      r = FactoryGirl.create(:registration, :existing, :overseas)
      r.voter_type.should == "Overseas / Military Absentee"
    end

    it 'should return domestic absentee' do
      r = FactoryGirl.create(:registration, :existing, :domestic_absentee)
      r.voter_type.should == "Domestic Absentee"
    end

    it 'should return residential voter' do
      r = FactoryGirl.create(:registration, :existing, :residential_voter)
      r.voter_type.should == "Residential Voter"
    end
  end

  describe 'verifying absentee until date on create' do
    it 'should not be farther than a year if letting to choose' do
      AppConfig['enable_uocava_end_date_choice'] = true
      r = FactoryGirl.create(:registration, absentee_until: 2.years.from_now)
      r.absentee_until.should be_within(1).of(1.year.from_now)
    end

    it 'should be set to the end of the current year if not choosing' do
      AppConfig['enable_uocava_end_date_choice'] = false
      r = FactoryGirl.create(:registration, absentee_until: 2.years.from_now)
      r.absentee_until.should be_within(1).of(1.year.from_now.end_of_year)
    end

    it 'should pass valid dates' do
      AppConfig['enable_uocava_end_date_choice'] = true
      r = FactoryGirl.create(:registration, absentee_until: 1.month.from_now)
      r.absentee_until.should be_within(1).of(1.month.from_now)

      AppConfig['enable_uocava_end_date_choice'] = false
      r = FactoryGirl.create(:registration, absentee_until: 1.month.from_now)
      r.absentee_until.should be_within(1).of(1.month.from_now)
    end
  end

  describe 'eligible?' do
    before { @old_ssn_required = AppConfig['ssn_required'] }
    after  { AppConfig['ssn_required'] = @old_ssn_required }

    specify { Registration.new(citizen: '1', old_enough: '1', dob: 30.years.ago, ssn: '123123123', rights_revoked: '0').should be_eligible }
    specify { Registration.new(citizen: '1', old_enough: '1', dob: 30.years.ago, ssn: '123123123', rights_revoked: '1', rights_felony: '1', rights_felony_restored: '1', rights_felony_restored_in: 'VA', rights_felony_restored_on: 15.years.ago).should be_eligible }
    specify { Registration.new(citizen: '0', old_enough: '1', dob: 30.years.ago, ssn: '123123123', rights_revoked: '0').should_not be_eligible }
    specify { Registration.new(citizen: '1', old_enough: '0', dob: 30.years.ago, ssn: '123123123', rights_revoked: '0').should_not be_eligible }
    specify { AppConfig['ssn_required'] = true;  Registration.new(citizen: '1', old_enough: '1', dob: 30.years.ago, ssn: '', no_ssn: '1', rights_revoked: '0').should_not be_eligible }
    specify { AppConfig['ssn_required'] = false; Registration.new(citizen: '1', old_enough: '1', dob: 30.years.ago, ssn: '', no_ssn: '1', rights_revoked: '0').should be_eligible }
    specify { Registration.new(citizen: '1', old_enough: '1', dob: 30.years.ago, ssn: '123123123', rights_revoked: '1').should_not be_eligible }
    specify { Registration.new(citizen: '1', old_enough: '1', dob: 30.years.ago, ssn: '123123123', rights_revoked: '1', rights_felony: '1', rights_felony_restored: '0').should_not be_eligible }
    specify { Registration.new(citizen: '1', old_enough: '1', dob: 30.years.ago, ssn: '123123123', rights_revoked: '1', rights_felony: '1', rights_felony_restored: '1').should_not be_eligible }
  end

  it 'should disallow paperless submission for TSC type of confidential address' do
    Registration.new(ca_type: 'TSC', is_confidential_address: '1').should_not be_paperless_submission_allowed
  end

  it 'should allow paperless submission' do
    Registration.new.should be_paperless_submission_allowed
  end
end
