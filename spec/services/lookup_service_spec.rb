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
    let(:election_id) { "6002FDB4-FC9C-4F36-A418-C0BDFFF2E579" }
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
        date:       '10 Oct 2012',
        notes:      'rejectUnsigned',
        registrar:  'York County General Registrar Clerk 17'
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

  def lookup(n)
    VCR.use_cassette("dmvid_#{n}") do
      LookupService.registration(dmv_id: n, ssn: '123123123', dob_day: '1', dob_month: '1', dob_year: '1976')
    end
  end

end
