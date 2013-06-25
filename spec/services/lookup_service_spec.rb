require 'spec_helper'

describe LookupService do

  describe 'registration' do
    specify { lookup('123456789012').should == { registered: true,  dmv_match: false } }
    specify { lookup('12345678901').should  == { registered: false, dmv_match: false } }
    specify { lookup('1234567890').should   == { registered: false, dmv_match: false } }
    specify do
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
  end

  def lookup(n)
    VCR.use_cassette("dmvid_#{n}") do
      LookupService.registration(dmv_id: n)
    end
  end

end
