require 'spec_helper'

describe RegistrationsController do

  let(:current_registration) { stub }
  before { controller.stub(:current_registration).and_return(current_registration) }

  describe 'create' do
    describe 'successfully' do
      before  { post :create, registration: {} }
      it      { should render_template :show }
      specify { session[:registration_id].should == assigns(:registration).id }
    end

    describe 'failed' do
      let(:req) { stub }
      before  { Registration.stub(:new).and_return(req) }
      before  { req.should_receive(:save).and_return(false) }
      before  { post :create, registration: {} }
      it      { should render_template :new }
      specify { flash[:error].should =~ /review/ }
    end
  end

  describe 'show' do
    it 'should render template with saved registration' do
      controller.should_receive(:current_registration).and_return(current_registration)
      get :show, format: 'pdf'
      should render_template :show
    end

    it 'should redirect to new registration page if there is no registration' do
      controller.should_receive(:current_registration).and_return(nil)
      get :show
      should redirect_to :root
    end
  end

  describe 'show' do
    before  { get :show }
    specify { assigns(:registration).should == current_registration }
    it      { should render_template :show }
  end

  describe 'edit' do
    before  { get :edit }
    specify { assigns(:registration).should == current_registration }
    it      { should render_template :edit }
  end

  describe 'update' do
    context 'valid' do
      before  { current_registration.should_receive(:update_attributes).and_return(true) }
      before  { put :update, registration: {} }
      specify { assigns(:registration).should == current_registration }
      it      { should render_template :update }
    end

    context 'invalid' do
      before  { current_registration.should_receive(:update_attributes).and_return(false) }
      before  { put :update, registration: {} }
      it      { should redirect_to :edit_registration }
    end
  end
end
