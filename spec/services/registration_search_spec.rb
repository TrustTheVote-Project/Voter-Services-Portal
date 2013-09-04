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
    its(:dob)                     { should == Date.parse("2013-06-25") }
    its(:rights_revoked)          { should == "0" }

    its(:vvr_address_1)           { should == "RR 507 Back woods" }
    its(:vvr_address_2)           { should == "" }
    its(:vvr_county_or_city)      { should == "TAZEWELL COUNTY" }
    its(:vvr_town)                { should == "N Tazewell" }
    its(:vvr_zip5)                { should == "24630" }
    its(:vvr_zip4)                { should == nil }

    # its(:ma_is_different)         { should == "1" }
    # its(:ma_address)              { should == "PO Box 870" }
    # its(:ma_city)                 { should == "North Tazewell" }
    # its(:ma_state)                { should == "VA" }
    # its(:ma_zip5)                 { should == "24630" }
    # its(:ma_zip4)                 { should == "0870" }

    its(:is_confidential_address) { should == "0" }

    its(:poll_precinct)           { should == "209 - JEFFERSONVILLE" }
    its(:poll_locality)           { should == "TAZEWELL COUNTY" }
    its(:poll_district)           { should == "SOUTHERN DISTRICT" }
    its(:poll_pricinct_split)     { should == "26161b72-080a-4af6-9e12-b596bd6db037" }

    its(:current_residence)       { should == "in" }
    its(:absentee_for_elections)  { should == [] }

    it 'should have previous registration data set' do
      r = subject
      r.pr_status.should      == '1'
      r.pr_cancel.should      == '0'
      r.pr_first_name.should  == "MOHAMED"
      r.pr_middle_name.should == "ASHLEY"
      r.pr_last_name.should   == "halperin"
      r.pr_suffix.should      == r.suffix

      r.pr_address.should     == "RR 507 Back woods"
      r.pr_address_2.should   == ""
      r.pr_city.should        == "N Tazewell"
      r.pr_state.should       == "VA"
      r.pr_zip5.should        == "24630"
      r.pr_zip4.should        == nil
      r.pr_is_rural.should    == '0'
    end
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
        r.voting_location.should    == "NUCKOLLS HALL, 515 FAIRGROUND RD, N TAZEWELL, VA, 24630"
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
        r.voting_location.should    be_blank
      end
    end
  end

  describe 'electoral_board_contacts' do
    context 'given' do
      let(:r) { search(600000008, 'TAZEWELL COUNTY') }
      it 'should be set' do
        r.electoral_board_contacts.should == "2769881305, PO BOX 201, TAZEWELL, VA, 24651-0201"
      end
    end

    context 'not given' do
      let(:r) { search(600000027, 'FAIRFAX COUNTY') }
      it 'should be blank' do
        r.electoral_board_contacts.should be_blank
      end
    end
  end

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
    its(:vvr_address_1)     { should == "5562 Ascot Ct Apt A" }
    its(:vvr_address_2)     { should == "Apt A" }
    its(:vvr_town)          { should == "Alexandria" }
    its(:vvr_zip5)          { should == "22311" }
    its(:vvr_zip4)          { should == "5562" }
  end

  # describe 'overseas mailing address' do
  #   context 'non-apo' do
  #     subject { search(600000048, 'ALBEMARLE COUNTY') }
  #     its(:mau_type)        { should == "non-us" }
  #     its(:mau_address)     { should == "335 Portico Bay flat 1" }
  #     its(:mau_address_2)   { should == nil }
  #     its(:mau_city)        { should == "Rome" }
  #     its(:mau_city_2)      { should == nil }
  #     its(:mau_state)       { should == "" }
  #     its(:mau_postal_code) { should == "123ERTv3" }
  #     its(:mau_country)     { should == "IT" }
  #   end

  #   context 'apo/dpo/fpo' do
  #     subject { search(600000038, 'ARLINGTON COUNTY') }
  #     its(:mau_type)        { should == "apo" }
  #     its(:apo_address)     { should == "UNIT 3050 Box 63" }
  #     its(:apo_address_2)   { should == nil }
  #     its(:apo_city)        { should == "DPO" }
  #     its(:apo_state)       { should == "AA" }
  #     its(:apo_zip5)        { should == "34025" }
  #   end

  #   it 'should parse address line types 1 and 3' do
  #     s = search(999999998, 'FAIRFAX COUNTY')
  #     s.apo_address.should    == "UNIT 45004 Box 201"
  #     s.apo_address_2.should  == "Apo, AP 963375004"
  #   end
  # end

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

  it 'should log the error when there is no gender' do
    RegistrationSearch.should_receive(:parse).and_return(Registration.new(voter_id: 123))
    ErrorLogRecord.should_receive(:log).with("Parsing error", error: "no gender", voter_id: 123)
    search(600000006, 'ALEXANDRIA CITY')
  end

  describe 'handle_response' do
    let(:c) { "400" }
    let(:b) { "error body" }

    it 'should handle 200' do
      RegistrationSearch.handle_response(stub(code: "200", body: "xml")).should == "xml"
    end

    it 'should handle unknown 400 error code' do
      ErrorLogRecord.should_receive(:log).with("Lookup: unknown error", code: c, body: b)
      LogRecord.should_receive(:lookup_error).with(b)
      lambda {
        RegistrationSearch.handle_response(stub(code: c, body: b))
      }.should raise_error RegistrationSearch::RecordNotFound
    end

    it 'should handle unknown 401' do
      ErrorLogRecord.should_receive(:log).with("Lookup: unknown error", code: "401", body: b)
      LogRecord.should_receive(:lookup_error).with(b)
      lambda {
        RegistrationSearch.handle_response(stub(code: "401", body: b))
      }.should raise_error RegistrationSearch::RecordNotFound
    end

    it 'should handle 404 w/o logging' do
      ErrorLogRecord.should_not_receive(:log)
      LogRecord.should_not_receive(:lookup_error)
      lambda {
        RegistrationSearch.handle_response(stub(code: "404", body: b))
      }.should raise_error RegistrationSearch::RecordNotFound
    end
  end

  private

  def search(n, loc)
    VCR.use_cassette("vid_#{n}") do
      RegistrationSearch.perform(query_for(n, loc))
    end
  end

  def query_for(n, loc)
    stub(voter_id: n, locality: loc, first_name: '1', dob: Date.parse('2013-06-25'))
  end

  def for_election(id)
    old = AppConfig['current_election']['uid']
    AppConfig['current_election']['uid'] = id

    yield

    AppConfig['current_election']['uid'] = old
  end

end
