require 'spec_helper'

describe LookupService do

  it 'should loopback the lookup' do
    AppConfig['enable_dmvid_lookup'] = false
    lookup('123456789').should == { registered: false, dmv_match: false }
  end

  it 'should not perform a lookup if DMV ID is missing' do
    LookupService.should_not_receive(:send_request)
    LookupService.registration(dmv_id: nil).should == { registered: false, dmv_match: false }
  end

  it 'should perform a real lookup' do
    AppConfig['enable_dmvid_lookup'] = true
    lookup('123456789').should == {
      registered: false,
      dmv_match:  true,
      address: {
        address_1:      "2228 MCKANN AVE",
        address_2:      "APT 12",
        county_or_city: "NORFOLK CITY",
        town:           "NORFOLK",
        zip5:           "23509"
      }
    }
  end

  def lookup(n)
    VCR.use_cassette("dmvid_#{n}") do
      LookupService.registration(dmv_id: n)
    end
  end

end
