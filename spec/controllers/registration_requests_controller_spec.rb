require 'spec_helper'

describe RegistrationRequestsController do

  describe 'create' do
    before { RegistrationRequest.should_receive(:create) }
    before { post :create, registration_request: {} }
    it     { should render_template :return_application }
  end

end
