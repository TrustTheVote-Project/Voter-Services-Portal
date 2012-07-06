require 'spec_helper'

describe SearchQuery do
  describe 'to_log_details' do
    it 'should return log details' do
      sq = SearchQuery.new(first_name: 'Mike', last_name: 'Jordan', locality: 'Some place', dob: Date.parse('1977-07-05'), voter_id: '123123123')
      sq.to_log_details.should == "Mike / Jordan / 1977-07-05 / Some place / 123123123"
    end

    it 'should return empty log details' do
      sq = SearchQuery.new()
      sq.to_log_details.should == ""
    end
  end
end
