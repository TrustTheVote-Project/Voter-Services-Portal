require 'spec_helper'

describe Api::RegistrationsController, :focus do

  it 'should return an error if the query parameters are invalid' do
    get :show
    response.should be_error
    assigns(:json_response).should == { 'success' => false, 'error' => 'Invalid search parameters' }
  end

  it 'should return existing record by voter ID' do
    get :show, voter_id: 600000000, locality: 'NORFOLK CITY'
    response.should be_success

    r = assigns(:json_response)
    r['success'].should be_true
    r['record'].should be
  end

  it 'should return existing record by SSN'

  it 'should return 404 when not found'

end
