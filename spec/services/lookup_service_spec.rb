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
          zip5:           "23454"
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
          zip5:           "23509"
        }
      })
    end

    it 'should hit protected record' do
      expect(lookup('000000001')).to eq({ registered: true, dmv_match: true })
    end
  end

  def lookup(n)
    VCR.use_cassette("dmvid_#{n}") do
      LookupService.registration(dmv_id: n, ssn: '123123123', dob_day: '1', dob_month: '1', dob_year: '1976')
    end
  end

end
