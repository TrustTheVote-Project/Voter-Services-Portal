require 'spec_helper'

describe RegistrationRepository do

  let(:session) { Hash.new }
  let(:registration) { FactoryGirl.build(:registration) }

  before  { RegistrationRepository.store_registration(session, registration) }

  describe 'persisting registration' do
    specify { session[:registration_id].should == Registration.first.id }
    specify { RegistrationRepository.get_registration(session).should == registration }
  end

  describe 'removing registration' do
    before  { RegistrationRepository.remove_registration(session) }
    specify { session.should_not be_include :registration_id }
  end

  describe 'storing search query data' do
    it 'should store empty query' do
      RegistrationRepository.store_search_query(session, SearchQuery.new)
      RegistrationRepository.pop_search_query(session).should == {
        lookup_type: 'ssn4', first_name: nil, last_name: nil, dob: nil, ssn4: nil, locality: nil, voter_id: nil }
    end

    it 'should store query' do
      RegistrationRepository.store_search_query(session, SearchQuery.new(lookup_type: 'vid', first_name: 'John', last_name: 'Smith', dob: Date.today))
      RegistrationRepository.pop_search_query(session).should == {
        lookup_type: 'vid', first_name: 'John', last_name: 'Smith', dob: Date.today, ssn4: nil, locality: nil, voter_id: nil }
    end
  end

  describe 'query data' do
    let(:dob) { 48.years.ago.to_date }
    let(:ssn4) { '1234' }
    let(:data) { { dob: dob, ssn4: ssn4 } }

    before  { RegistrationRepository.store_lookup_data(session, SearchQuery.new(data)) }
    specify { RegistrationRepository.get_lookup_ssn4(session).should == ssn4 }
    specify { RegistrationRepository.pop_lookup_data(session).should == data }
  end

  describe 'restore search session' do
    subject { RegistrationRepository.restore_search_query_options(session) }

    context 'empty session' do
      let(:session) { {} }
      it 'empty' do
        expect(subject).to be_empty
      end
    end

    context 'classic session' do
      let(:session) { { s_first_name: 'fn', s_last_name: 'ln', s_date_of_birth: '1990-01-31'} }
      it 'filled' do
        expect(subject).to be_eql(first_name: 'fn', last_name: 'ln', date_of_birth: Date.parse('1990-01-31'))
      end
    end

  end
end
