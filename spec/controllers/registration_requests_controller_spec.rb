require 'spec_helper'

describe RegistrationRequestsController do

  describe 'create' do
    describe 'successfully' do
      before  { post :create, registration_request: {} }
      it      { should render_template :show }
      specify { session[:regreq_id].should == assigns(:registration_request).id }
    end

    describe 'failed' do
      let(:req) { stub }
      before  { RegistrationRequest.stub(:new).and_return(req) }
      before  { req.should_receive(:save).and_return(false) }
      before  { post :create, registration_request: {} }
      it      { should render_template :new }
      specify { flash[:error].should =~ /review/ }
    end
  end

  describe 'show' do
    it 'should render template with saved registration' do
      req = Factory(:registration_request)
      controller.should_receive(:last_registration_request).and_return(req)
      get :show, format: 'pdf'
      should render_template :show
    end

    it 'should redirect to new registration page if there is no registration' do
      controller.should_receive(:last_registration_request).and_raise(ActiveRecord::RecordNotFound)
      get :show
      should redirect_to :new_registration_request
    end
  end
end
