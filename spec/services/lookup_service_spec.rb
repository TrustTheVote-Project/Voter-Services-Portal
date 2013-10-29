require 'spec_helper'

describe LookupService do

  let(:no_match) { { registered: false, dmv_match: false } }

  it 'should loopback the lookup' do
    AppConfig['enable_dmvid_lookup'] = false
    expect(lookup('123456789')).to eq no_match
  end

  context 'complete record' do
    before { AppConfig['enable_dmvid_lookup'] = true }

    it 'should return SBE=false Match=true' do
      expect(lookup('000000002')).to eq({
        registered: false,
        dmv_match:  true,
        address: {
          address_1:      "1318 RIVA RIDGE RUN",
          address_2:      "",
          town:           "VIRGINIA BEACH",
          zip5:           "23454",
          zip4:           "5527"
        }
      })
    end

    it 'should return SBE=true Match=true' do
      expect(lookup('000000006')).to eq({
        registered: true,
        dmv_match:  true,
        address: {
          address_1:      "2228 MCKANN AVE",
          address_2:      "",
          town:           "NORFOLK",
          zip5:           "23509",
          zip4:           "2235"
        }
      })
    end

    it 'should hit protected record' do
      expect(lookup('000000001')).to eq({ registered: true, dmv_match: true })
    end
  end

  describe 'absentee_status_history' do
    let(:voter_id)    { '600000000' }
    let(:election_id) { "68c30477-aaf2-46dd-994e-5d3be8a89c9b" }
    let(:dob)         { Date.parse('2013-09-04') }
    let(:locality)    { 'NORFOLK CITY' }

    it 'should return elections details' do
      LookupService.should_receive(:collect_election_ids_for_voter).with(voter_id).and_return([ election_id ])
      LookupService.should_receive(:collect_elections_details).with(voter_id, [ election_id ], dob, locality)
      LookupService.absentee_status_history(voter_id, dob, locality)
    end

    it 'should collect election ids', :vcr do
      ids = LookupService.send(:collect_election_ids_for_voter, voter_id)
      expect(ids).to eq [ election_id ]
    end

    it 'should collect election details', :vcr do
      res = LookupService.send(:collect_elections_details, voter_id, [ election_id ], dob, locality)
      expect(res.size).to eq 6
      expect(res[2]).to eq({
        request:    'AbsenteeRequest',
        action:     'reject',
        date:       'Oct 10, 2012',
        notes:      'rejectUnsigned',
        registrar:  'York County General Registrar Clerk 17',
        form_notes: ''
      })
    end
  end

  describe 'ballot_info' do
    let(:voter_id)    { '600000000' }
    let(:election_id) { "6002FDB4-FC9C-4F36-A418-C0BDFFF2E579" }

    it 'should return ballot info', :vcr do
      info = LookupService.ballot_info(voter_id, election_id)

      # header
      expect(info[:election][:name]).to eq "2012 November General"
      expect(info[:election][:date]).to eq Date.parse('2012-11-06')
      expect(info[:locality]).to eq "FAIRFAX COUNTY"
      expect(info[:precinct]).to eq "609 - MARLAN"

      # contests
      cs = info[:contests]
      expect(cs.size).to eq 9
      expect(cs[0]).to eq(sort_order: 1, type: 'Contest', office: 'President and Vice President', candidates: [
        { name: 'Barack Obama', sort_order: 1, candidate_url: 'http://www.barackobama.com', party: 'Democrat', email: nil },
        { name: 'Mitt Romney',  sort_order: 2, candidate_url: 'http://www.mittromney.com', party: 'Republican', email: 'info@mittromney.com' },
        { name: 'Gary Johnson', sort_order: 3, candidate_url: 'http://www.garyjohnson2012.com', party: 'Libertarian', email: nil },
        { name: 'Virgil Goode', sort_order: 6, candidate_url: 'http://www.goodeforpresident2012.com', party: 'Constitution', email: nil },
        { name: 'Jill Stein',   sort_order: 7, candidate_url: 'http://www.jillstein.org', party: 'Green', email: 'wolf@jillstein.org' }
      ])

      expect(cs[4]).to eq(sort_order: 102, type: 'Referendum', office: 'Proposed Constitutional Amendment Question 2', candidates: [
        { name: 'Shall Section 6 of Article IV (Legislature) of the Constitution of Virginia concerning legislative sessions be amended to allow the General Assembly to delay by no more than one week the fixed starting date for the reconvened or "veto" session when the General Assembly meets after a session to consider the bills returned to it by the Governor with vetoes or amendments?' }
      ])
    end

    it 'should raise error', :vcr do
      expect {
        LookupService.ballot_info(nil, nil)
      }.to raise_error LookupApi::RecordNotFound
    end
  end

  describe "response parsing" do
    describe "#parse_elections_xml" do
      let(:res) { [ { id: "68c30477-aaf2-46dd-994e-5d3be8a89c9b", name: "2012 November General" } ] }

      it 'should parse valid response with elections list (vip root node)' do
        expect(parse_elections_xml('vip.xml')).to eq res
      end

      it 'should parse valid response with elections list (vip_object root node)' do
        expect(parse_elections_xml('vip_object.xml')).to eq res
      end

      def parse_elections_xml(filename)
        xml = fixture("api/elections/#{filename}").read
        LookupService.send(:parse_elections_xml, xml)
      end
    end

    describe "#parse_transaction_log_xml" do
      it 'should parse data' do
        xml = fixture("api/transactions/data.xml").read
        res = LookupService.send(:parse_transaction_log_xml, xml)
        expect(res).to eq [ { request: "AbsenteeRequest", action: "start", date: "Feb 06, 2013", registrar: "ehibner-reavis", notes: "", form_notes: "" } ]
      end
    end

    describe '#parse_ballot_xml' do
      it 'should parse data' do
        xml = fixture("api/ballots/data.xml").read
        res = LookupService.send(:parse_ballot_xml, xml)
        expect(res).to eq({
          election: {
            name: "2012 November General",
            date: Date.parse("2012-11-06")
          },

          locality: "ARLINGTON COUNTY",
          precinct: "046 - CENTRAL",

          contests: [
            { type: "Contest", sort_order: 1, office: "President and Vice President", candidates: [
              { name: "Barack Obama", sort_order: 1, candidate_url: "http://www.barackobama.com", party: "Democrat", email: nil},
              { name: "Virgil Goode", sort_order: 1, candidate_url: "http://www.goodeforpresident2012.com", party: "Constitution", email: nil},
              { name: "Mitt Romney", sort_order: 2, candidate_url: "http://www.mittromney.com", party: "Republican", email: "info@mittromney.com"},
              { name: "Gary Johnson", sort_order: 3, candidate_url: "http://www.garyjohnson2012.com", party: "Libertarian", email: nil},
              { name: "Jill Stein", sort_order: 7, candidate_url: "http://www.jillstein.org", party: "Green", email: "wolf@jillstein.org"}]},
            { type: "Contest", sort_order: 2, office: "United States Senate", candidates: [
              { name: "Timothy M. Kaine", sort_order: 1, candidate_url: "http://www.kaineforva.com", party: "Democrat", email: "tmk@kaineforva.com"},
              { name: "George F. Allen", sort_order: 2, candidate_url: "http://www.georgeallen.com", party: "Republican", email: "mike.thomas@georgeallen.com"}]},
            { type: "Contest", sort_order: 3, office: "Member House of Representatives", candidates: [
              { name: "James P. \"Jim\" Moran, Jr.", sort_order: 1, candidate_url: "http://www.jimmoran.org", party: "Democrat", email: "mmoran@moranforcongress.org"},
              { name: "J. Patrick Murray", sort_order: 2, candidate_url: "http://www.patrickmurrayforcongress.com", party: "Republican", email: "patrick@murrayforcongress.com"},
              { name: "Jason J. Howell", sort_order: 4, candidate_url: "http://www.votejasonhowell.com", party: "Independent", email: "jason@votejasonhowell.com"},
              { name: "Janet Murphy", sort_order: 6, candidate_url: "http://http:www.votejoinrun.us", party: "Independent Green", email: "jastarlings@gmail.com"}]},
            { type: "Contest", sort_order: 16, office: "Member County Board", candidates: [
              { name: "Libby T. Garvey", sort_order: 1, candidate_url: "http://www.libbygarvey.com", party: "Democrat", email: "info@libbygarvey.com"},
              { name: "Matthew A. Wavro", sort_order: 2, candidate_url: "http://www.wavro2012.com", party: "Republican", email: "matt.wavro@gmail.com"},
              { name: "Audrey R. Clement", sort_order: 4, candidate_url: "http://www.audreyclement.org", party: "Independent", email: "info@audreyclement.org"}]},
            { type: "Contest", sort_order: 25, office: "Member School Board", candidates: [
              { name: "Emma N. Violand-Sanchez", sort_order: 4, candidate_url: "http://www.emmaforschoolboard.org", party: "Independent", email: "emma@emmaforschoolboard.org"},
              { name: "Noah L. Simon", sort_order: 4, candidate_url: "http://www.noahsimon.org", party: "Independent", email: "noah_simon@verizon.net"}]},
            { type: "Referendum", sort_order: 101, office: "Proposed Constitutional Amendment Question 2", candidates: [ { name: "Shall Section 6 of Article IV (Legislature) of the Constitution of Virginia concerning legislative sessions be amended to allow the General Assembly to delay by no more than one week the fixed starting date for the reconvened or \"veto\" session when the General Assembly meets after a session to consider the bills returned to it by the Governor with vetoes or amendments?"}]},
            { type: "Referendum", sort_order: 101, office: "Proposed Constitutional Amendment Question 1", candidates: [ { name: "Shall Section 11 of Article I (Bill of Rights) of the Constitution of Virginia be amended (i) to require that eminent domain only be exercised where the property taken or damaged is for public use and, except for utilities or the elimination of a public nuisance, not where the primary use is for private gain, private benefit, private enterprise, increasing jobs, increasing tax revenue, or economic development; (ii) to define what is included in just compensation for such taking or damaging of property; and (iii) to prohibit the taking or damaging of more private property than is necessary for the public use?"}]},
            { type: "Referendum", sort_order: 105, office: "Community Infrastructure", candidates: [ {name: "Shall Arlington County contract a debt and issue its general obligation bonds in the maximum principal amount of $28,306,000 to finance, together with other available funds, the cost of various capital projects for County facilities, information technology, and infrastructure?"}]},
            { type: "Referendum", sort_order: 105, office: "Local Parks and Recreation", candidates: [ { name: "Shall Arlington County contract a debt and issue its general obligation bonds in the maximum principal amount of $50,553,000 to finance, together with other available funds, the cost of various capital projects for local parks  recreation, and land acquisition for parks and open space?"}]},
            { type: "Referendum", sort_order: 105, office: "Metro and Transportation", candidates: [ { name: "Shall Arlington County contract a debt and issue its general obligation bonds in the maximum principal amount of $31,946,000 to finance, together with other available funds, the cost of various capital projects for the Washington Metropolitan Area Transit Authority and other transit, pedestrian, road or transportation projects?"}]},
            { type: "Referendum", sort_order: 105, office: "Arlington Public Schools", candidates: [ { name: "Shall Arlington County contract a debt and issue its general obligation bonds in the maximum principal amount of $42,620,000 to finance, together with other available funds, the costs of various capital projects for Arlington Public Schools?"}]}
          ]
        })
      end
    end
  end

  describe 'voter_elections' do
    it 'should not return elections without ballots' do
      elections = [
        { id: 'id1', name: 'with ballots' },
        { id: 'id2', name: 'without ballots' }
      ]
      LookupService.should_receive(:all_voter_elections).and_return(elections)
      LookupService.should_receive(:has_ballot_for?).with(:vid, 'id1').and_return(true)
      LookupService.should_receive(:has_ballot_for?).with(:vid, 'id2').and_return(false)

      expect(LookupService.voter_elections(:vid)).to eq [ { id: 'id1', name: 'with ballots' } ]
    end
  end

  def lookup(n)
    VCR.use_cassette("dmvid_#{n}") do
      LookupService.registration(dmv_id: n, ssn: '123123123', dob_day: '1', dob_month: '1', dob_year: '1976')
    end
  end

end
