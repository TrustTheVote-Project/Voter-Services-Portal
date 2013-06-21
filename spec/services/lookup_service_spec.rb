require 'spec_helper'

describe LookupService do

  describe 'registration' do
    specify { LookupService.registration(dmv_id: '123456789012').should == { registered: true } }
    specify { LookupService.registration(dmv_id: '12345678901').should  == { registered: false, dmv_match: false } }
    specify { LookupService.registration(dmv_id: '1234567890').should   == { registered: false, dmv_match: false } }
    specify do
      LookupService.registration(dmv_id: '123456789').should == {
        registered: false,
        dmv_match:  true,
        address: {
          address_1:      "123 WannaVote DR",
          address_2:      "4",
          county_or_city: "ALEXANDRIA CITY",
          zip5:           "12345"
        }
      }
    end
  end

end
