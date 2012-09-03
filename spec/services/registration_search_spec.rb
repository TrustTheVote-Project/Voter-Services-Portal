require 'spec_helper'

describe RegistrationSearch do

  describe 'absentee, confidential, incapacitated, felony' do
    let(:q) { stub(voter_id: 600000027, locality: 'FAIRFAX COUNTY', first_name: 'Mark') }
    subject do
      VCR.use_cassette('vid_600000027') do
        RegistrationSearch.perform(q)
      end
    end

    it { should be_kind_of Registration }
    its(:first_name)              { should == "GREGORY" }
    its(:last_name)               { should == "FORSYTH" }
    its(:middle_name)             { should == "EARL" }
    its(:phone)                   { should == "8042693708" }
    its(:gender)                  { should == "Female" }
    its(:rights_revoked)          { should == "1" }
    its(:rights_revoked_reason)   { should == "mental" }
    its(:rights_restored)         { should == "1" }
    its(:rights_restored_on)      { should == Kronic.parse('2012-04-21') }

    its(:ma_is_same)              { should == "0" }
    its(:ma_address)              { should == "3213 Gaulding LN" }
    its(:ma_city)                 { should == "Henrico" }
    its(:ma_state)                { should == "VA" }
    its(:ma_zip5)                 { should == "23223" }
    its(:ma_zip4)                 { should == "" }

    its(:is_confidential_address) { should == "1" }

    its(:poll_precinct)           { should == "220 - RATCLIFFE" }
    its(:poll_locality)           { should == "HENRICO COUNTY" }
    its(:poll_district)           { should == "FAIRFIELD DISTRICT" }

    its(:ssn4)                    { should == "XXXX" }
    its(:current_residence)       { should == "in" }
    its(:current_absentee)        { should == "1" }
    its(:absentee_for_elections)  { should == [] }
  end

  describe 'absentee, confidential, incapacitated, felony' do
    let(:q) { stub(voter_id: 600000029, locality: 'VIRGINIA BEACH CITY', first_name: 'Mark') }
    subject do
      VCR.use_cassette('vid_600000029') do
        RegistrationSearch.perform(q)
      end
    end

    it { should be_kind_of Registration }
    its(:first_name)              { should == "KESHIA" }
    its(:last_name)               { should == "PRODAN" }
    its(:middle_name)             { should == "ROBERTSON" }
    its(:phone)                   { should == "7032463862" }
    its(:gender)                  { should == "Female" }
    its(:rights_revoked)          { should == "1" }
    its(:rights_revoked_reason)   { should == "mental" }
    its(:rights_restored)         { should == "0" }

    its(:ma_is_same)              { should == "0" }
    its(:ma_address)              { should == "18108 Oak Ridge DR" }
    its(:ma_city)                 { should == "Purcellville" }
    its(:ma_state)                { should == "VA" }
    its(:ma_zip5)                 { should == "20132" }
    its(:ma_zip4)                 { should == "4049" }

    its(:poll_precinct)           { should == "301 - PURCELLVILLE ONE" }
    its(:poll_locality)           { should == "LOUDOUN COUNTY" }
    its(:poll_district)           { should == "BLUE RIDGE DISTRICT" }

    its(:ssn4)                    { should == "XXXX" }
    its(:current_residence)       { should == "in" }
    its(:current_absentee)        { should == "1" }
    its(:absentee_for_elections)  { should == [] }
  end
end
