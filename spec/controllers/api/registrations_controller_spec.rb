require 'spec_helper'

describe Api::RegistrationsController do

  let(:r) { FactoryGirl.build(:existing_residential_voter) }

  it 'should return existing record by voter ID' do
    expect(RegistrationSearch).to receive(:perform).and_return(r)
    get :show, voter_id: 600000000, locality: 'NORFOLK CITY', format: 'json'
    response.should be_success
  end

  it 'should return existing record by SSN' do
    expect(RegistrationSearch).to receive(:perform).and_return(r)
    get :show, ssn4: '1234', first_name: 'F', last_name: 'L', dob: '1979-10-24', locality: 'NORFOLK CITY', format: 'json'
    assigns(:query).dob.strftime("%Y-%m-%d").should == "1979-10-24"
    response.should be_success
  end

  it 'should incomplete search' do
    get :show
    response.should be_error
    assigns(:json_response).should == { 'success' => false, 'error' => 'Invalid search parameters' }
  end

  it 'should catch incomplete SSN-based search' do
    get :show, ssn4: '1234'
    response.should be_error
  end

  it 'should catch incomplete VoterID-based search' do
    get :show, voter_id: '1234'
    response.should be_error
  end

  it 'should return 404 when not found' do
    allow_any_instance_of(SearchQuery).to receive(:valid?).and_return(true)
    expect(RegistrationSearch).to receive(:perform).and_raise(RegistrationSearch::RecordNotFound)
    get :show
    response.should be_error

    assigns(:json_response).should == { 'success' => false, 'error' => 'Record not found' }
  end

  it 'should support JSONP' do
    allow_any_instance_of(SearchQuery).to receive(:valid?).and_return(true)
    expect(RegistrationSearch).to receive(:perform).and_return(r)
    get :show, cb: 'fn', format: 'json'

    response.body.should =~ /^fn\(.*\)$/
  end

end
