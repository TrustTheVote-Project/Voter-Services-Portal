require 'spec_helper'

describe RegistrationSearch do

  describe 'general' do
    subject { search(8, 'TAZEWELL COUNTY') }

    it { should be_kind_of Registration }
    its(:voter_id)                { should == "600000008" }
    its(:first_name)              { should == "MOHAMED" }
    its(:middle_name)             { should == "ASHLEY" }
    its(:last_name)               { should == "halperin" }
    its(:phone)                   { should == "2769882415" }
    its(:gender)                  { should == "Female" }
    its(:rights_revoked)          { should == "0" }

    its(:vvr_street_number)       { should == "507" }
    its(:vvr_street_name)         { should == "4th" }
    its(:vvr_street_type)         { should == "ST" }
    its(:vvr_apt)                 { should == nil }
    its(:vvr_town)                { should == "N Tazewell" }
    its(:vvr_zip5)                { should == "24630" }
    its(:vvr_zip4)                { should == nil }

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
    its(:absentee_for_elections)  { should == [] }
  end

  # John: Ignoring incapacitated / felony until we get samples of restored rights
  #
  # describe 'incapacitated' do
  #   subject { search(11, 'HARRISONBURG CITY') }
  #   its(:rights_revoked)          { should == '1' }
  #   its(:rights_revoked_reason)   { should == 'mental' }
  #   its(:rights_restored)         { should == '0' }
  # end
  #
  # describe 'convicted' do
  #   subject { search(18, 'VIRGINIA BEACH CITY') }
  #   its(:rights_revoked)          { should == '1' }
  #   its(:rights_revoked_reason)   { should == 'felony' }
  #   its(:rights_restored)         { should == '0' }
  # end

  describe 'ongoing absentee' do
    subject { search(24, 'ALEXANDRIA CITY') }
    its(:current_absentee_until)  { should == Date.parse('2012-12-31') }
  end

  describe 'military ongoing absentee' do
    subject { search(36, 'CHESAPEAKE CITY') }
    its(:current_absentee_until)  { should == Date.today.advance(years: 1).end_of_year }
  end

  describe 'election-level absentee' do
    subject { search(27, 'FAIRFAX COUNTY') }
    its(:absentee_for_elections)  { should == [ '2012 November General' ] }
  end

  describe 'overseas mailing address' do
    context 'non-apo' do
      subject { search(36, 'CHESAPEAKE CITY') }
      its(:mau_type)        { should == "non-us" }
      its(:mau_address)     { should == "1417 Great Bridge Blvd" }
      its(:mau_address_2)   { should == "" }
      its(:mau_city)        { should == "Chesapeake" }
      its(:mau_city_2)      { should == nil }
      its(:mau_state)       { should == "VA" }
      its(:mau_postal_code) { should == "233206421" }
      its(:mau_country)     { should == "US" }
    end

    context 'apo/dpo/fpo' do
      subject { search(38, 'ARLINGTON COUNTY') }
      its(:mau_type)        { should == "apo" }
      its(:apo_address)     { should == "UNIT 3050 Box 63" }
      its(:apo_address_2)   { should == "" }
      its(:apo_1)           { should == "DPO" }
      its(:apo_2)           { should == "AA" }
      its(:apo_zip5)        { should == "34025" }
    end
  end

  describe 'elections for absentee request' do
    subject { search(9, "NEWPORT NEWS CITY") }
    its(:upcoming_elections) { should == [
      "2012 November General",
      "2013 November General",
      "2014 May City General",
      "2014 November General",
      "2015 November General",
      "2019 November General"
    ] }
  end

  private

  def search(n, loc)
    VCR.use_cassette("vid_#{600000000 + n}") do
      RegistrationSearch.perform(query_for(n, loc))
    end
  end

  def query_for(n, loc)
    stub(voter_id: 600000000 + n, locality: loc, first_name: '1')
  end

end
