require 'spec_helper'

describe RegistrationSearch do
  it 'should find record by voter_id' do
    RegistrationSearch.perform(SearchQuery.new(voter_id: '1234-1234-1234-1234')).should be
  end

  it 'should not find record' do
    RegistrationSearch.perform(SearchQuery.new(voter_id: '1234')).should_not be
  end

  it 'should find record by data' do
    RegistrationSearch.perform(SearchQuery.new(
      last_name: 'phepts',
      'dob(3i)' => '6', 'dob(2i)' => '11', 'dob(1i)' => '1950',
      ssn4: '6789')).first_name.should == 'Wanda'
  end

  it 'should not fund record by name' do
    RegistrationSearch.perform(SearchQuery.new(
      last_name: 'phepts',
      'dob(3i)' => '6', 'dob(2i)' => '11', 'dob(1i)' => '1950',
      ssn4: '7777')).should be_nil
  end
end
