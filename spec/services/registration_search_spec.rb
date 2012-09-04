require 'spec_helper'

describe RegistrationSearch do

  describe 'general' do
    let(:q) { stub(voter_id: 600000008, locality: 'TAZEWELL COUNTY', first_name: '1') }
    subject do
      VCR.use_cassette('vid_600000008') do
        RegistrationSearch.perform(q)
      end
    end

    it { should be_kind_of Registration }
    its(:first_name)              { should == "MOHAMED" }
    its(:middle_name)             { should == "ASHLEY" }
    its(:last_name)               { should == "halperin" }
    its(:phone)                   { should == "2769882415" }
    its(:gender)                  { should == "Female" }
    its(:rights_revoked)          { should == "0" }

    its(:ma_is_same)              { should == "0" }
    its(:ma_address)              { should == "PO Box 870" }
    its(:ma_city)                 { should == "North Tazewell" }
    its(:ma_state)                { should == "VA" }
    its(:ma_zip5)                 { should == "24630" }
    its(:ma_zip4)                 { should == "0870" }

    its(:is_confidential_address) { should == "0" }

    its(:poll_precinct)           { should == "209 - JEFFERSONVILLE" }
    its(:poll_locality)           { should == "TAZEWELL COUNTY" }
    its(:poll_district)           { should == "SOUTHERN DISTRICT" }

    its(:ssn4)                    { should == "XXXX" }
    its(:current_residence)       { should == "in" }
    its(:current_absentee)        { should == "0" }
    its(:absentee_for_elections)  { should == [] }
  end

  # describe 'absentee, confidential, incapacitated, felony' do
  #   let(:q) { stub(voter_id: 600000029, locality: 'VIRGINIA BEACH CITY', first_name: 'Mark') }
  #   subject do
  #     VCR.use_cassette('vid_600000029') do
  #       RegistrationSearch.perform(q)
  #     end
  #   end

  #   it { should be_kind_of Registration }
  #   its(:first_name)              { should == "KESHIA" }
  #   its(:last_name)               { should == "PRODAN" }
  #   its(:middle_name)             { should == "ROBERTSON" }
  #   its(:phone)                   { should == "7032463862" }
  #   its(:gender)                  { should == "Female" }
  #   its(:rights_revoked)          { should == "1" }
  #   its(:rights_revoked_reason)   { should == "mental" }
  #   its(:rights_restored)         { should == "0" }

  #   its(:ma_is_same)              { should == "0" }
  #   its(:ma_address)              { should == "18108 Oak Ridge DR" }
  #   its(:ma_city)                 { should == "Purcellville" }
  #   its(:ma_state)                { should == "VA" }
  #   its(:ma_zip5)                 { should == "20132" }
  #   its(:ma_zip4)                 { should == "4049" }

  #   its(:poll_precinct)           { should == "301 - PURCELLVILLE ONE" }
  #   its(:poll_locality)           { should == "LOUDOUN COUNTY" }
  #   its(:poll_district)           { should == "BLUE RIDGE DISTRICT" }

  #   its(:ssn4)                    { should == "XXXX" }
  #   its(:current_residence)       { should == "in" }
  #   its(:current_absentee)        { should == "1" }
  #   its(:absentee_for_elections)  { should == [] }
  # end

  # describe 'finding by data' do
  #   let(:q) { stub(ssn4: 0006, locality: 'ALEXANDRIA CITY', first_name: 'JENNIFER', last_name: 'NAHLEY', dob: Date.parse('1926-10-13')) }

  #   subject do
  #     VCR.use_cassette('data_600000006') do
  #       RegistrationSearch.perform(q)
  #     end
  #   end

  #   it { should be_kind_of Registration }
  # end
end
