require 'spec_helper'

describe RegistrationSearch do

  describe 'general' do
    subject { search(600000008, 'TAZEWELL COUNTY') }

    it { should be_kind_of Registration }
    its(:voter_id)                { should == "600000008" }
    its(:first_name)              { should == "MOHAMED" }
    its(:middle_name)             { should == "ASHLEY" }
    its(:last_name)               { should == "halperin" }
    its(:phone)                   { should == "2769882415" }
    its(:gender)                  { should == "Female" }
    its(:rights_revoked)          { should == "0" }

    its(:vvr_street_number)       { should == "507" }
    its(:vvr_street_name)         { should == "Back woods" }
    its(:vvr_street_type)         { should == "ST" }
    its(:vvr_apt)                 { should == "" }
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

  describe 'gender parsing' do
    specify { search(600000001, 'FAIRFAX COUNTY').gender.should == 'Female' }
  end

  describe 'polling location' do
    context 'given' do
      let(:r) { search(600000008, 'TAZEWELL COUNTY') }
      it 'should have ppl_* set' do
        r.ppl_location_name.should  == "NUCKOLLS HALL"
        r.ppl_address.should        == "515 FAIRGROUND RD"
        r.ppl_city.should           == "N TAZEWELL"
        r.ppl_state.should          == "VA"
        r.ppl_zip.should            == "24630"
      end
    end

    context 'not given' do
      let(:r) { search(600000027, 'FAIRFAX COUNTY') }
      it 'should have blank ppl_*' do
        r.ppl_location_name.should  be_blank
        r.ppl_address.should        be_blank
        r.ppl_city.should           be_blank
        r.ppl_state.should          be_blank
        r.ppl_zip.should            be_blank
      end
    end
  end

  # John: Ignoring incapacitated / felony until we get samples of restored rights
  #
  # describe 'incapacitated' do
  #   subject { search(600000011, 'HARRISONBURG CITY') }
  #   its(:rights_revoked)          { should == '1' }
  #   its(:rights_revoked_reason)   { should == 'mental' }
  #   its(:rights_restored)         { should == '0' }
  # end
  #
  # describe 'convicted' do
  #   subject { search(600000018, 'VIRGINIA BEACH CITY') }
  #   its(:rights_revoked)          { should == '1' }
  #   its(:rights_revoked_reason)   { should == 'felony' }
  #   its(:rights_restored)         { should == '0' }
  # end

  describe 'districts' do
    subject { search(600000008, 'TAZEWELL COUNTY') }
    its(:districts) { should == [
      [ 'Congressional',  [ '09', '9th District' ] ],
      [ 'Senate',         [ '038', '38th District' ] ],
      [ 'State House',    [ '003', '3rd District' ] ],
      [ 'Local',          [ '', 'SOUTHERN DISTRICT' ] ] ] }
  end

  describe 'online balloting eligibility' do
    describe 'ongoing=no, electionlevel=no' do
      it 'should not be eligible' do
        r = search(600000000, 'NORFOLK CITY')
        r.should_not be_ob_eligible
        r.current_absentee_until.should be_nil
      end
    end

    describe 'ongoing=yes' do
      it 'should be eligible' do
        r = search(600000035, 'ARLINGTON COUNTY')
        r.should be_ob_eligible
        r.current_absentee_until.should == Date.parse('2012-12-31')
      end
    end

    describe 'electionlevel=yes' do
      it 'should be eligible if current election has approved Absentee section' do
        for_election('68c30477-aaf2-46dd-994e-5d3be8a89c9b') do
          r = search(600000021, 'ALEXANDRIA CITY')
          r.should be_ob_eligible
          r.current_absentee_until.should be_nil
        end
      end

      it 'should not be eligible if current election has non-approved Absentee section' do
        # no test case
      end

      it 'should not be eligible if current election is undefined' do
        for_election(nil) do
          r = search(600000031, 'MECKLENBURG COUNTY')
          r.should_not be_ob_eligible
        end
      end
    end
  end

  describe 'past elections' do
    subject { search(600000021, 'ALEXANDRIA CITY') }
    its(:past_elections) { should == [ [ "2008 November General", "Voted absentee" ] ] }
  end

  describe 'registration address' do
    subject { search(600000006, 'ALEXANDRIA CITY') }
    its(:vvr_street_number) { should == "5562" }
    its(:vvr_street_name)   { should == "Ascot" }
    its(:vvr_street_type)   { should == "CT" }
    its(:vvr_apt)           { should == "Apt A" }
    its(:vvr_town)          { should == "Alexandria" }
    its(:vvr_zip5)          { should == "22311" }
    its(:vvr_zip4)          { should == "5562" }
  end

  describe 'overseas mailing address' do
    context 'non-apo' do
      subject { search(600000048, 'ALBEMARLE COUNTY') }
      its(:mau_type)        { should == "non-us" }
      its(:mau_address)     { should == "335 Portico Bay flat 1" }
      its(:mau_address_2)   { should == "" }
      its(:mau_city)        { should == "Rome" }
      its(:mau_city_2)      { should == nil }
      its(:mau_state)       { should == "" }
      its(:mau_postal_code) { should == "123ERTv3" }
      its(:mau_country)     { should == "IT" }
    end

    context 'apo/dpo/fpo' do
      subject { search(600000038, 'ARLINGTON COUNTY') }
      its(:mau_type)        { should == "apo" }
      its(:apo_address)     { should == "UNIT 3050 Box 63" }
      its(:apo_address_2)   { should == "" }
      its(:apo_1)           { should == "DPO" }
      its(:apo_2)           { should == "AA" }
      its(:apo_zip5)        { should == "34025" }
    end
  end

  describe 'elections for absentee request' do
    subject { search(600000006, 'ALEXANDRIA CITY') }
    its(:upcoming_elections) { should == [
      "2012 November General",
      "2013 November General",
      "2014 November General",
      "2015 November General",
      "2019 November General"
    ] }
  end

  it 'should search by data' do
    VCR.use_cassette("vid_data") do
      query = SearchQuery.new(
        locality:   'NORFOLK CITY',
        first_name: 'FRANKIE',
        last_name:  'STEMPINSKI',
        dob:        Date.parse('1959-04-22'),
        ssn4:       '0000')

      res = RegistrationSearch.perform(query)
      res.should be_kind_of Registration
    end
  end

  describe 'error handling' do
    it 'should return not found when the record is not found' do
      lambda {
        search(600000002, 'UNKNOWN')
      }.should raise_error RegistrationSearch::RecordNotFound
    end

    it 'should raise error when times out' do
      lambda {
        RegistrationSearch.should_receive(:parse_uri_without_timeout).and_raise(Timeout::Error)
        search(600000009, 'NEWPORT NEWS CITY')
      }.should raise_error RegistrationSearch::LookupTimeout
    end

    it 'should handle confidental records' do
      lambda {
        search(600000009, 'NEWPORT NEWS CITY')
      }.should raise_error RegistrationSearch::RecordIsConfidential
    end

    it 'should handle inactive records' do
      lambda {
        search(600000018, 'VIRGINIA BEACH CITY')
      }.should raise_error RegistrationSearch::RecordIsInactive
    end
  end

  private

  def search(n, loc)
    VCR.use_cassette("vid_#{n}") do
      RegistrationSearch.perform(query_for(n, loc))
    end
  end

  def query_for(n, loc)
    stub(voter_id: n, locality: loc, first_name: '1')
  end

  def for_election(id)
    old = AppConfig['current_election']['uid']
    AppConfig['current_election']['uid'] = id

    yield

    AppConfig['current_election']['uid'] = old
  end

end
