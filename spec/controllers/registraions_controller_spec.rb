require 'spec_helper'

describe RegistrationsController do

  let(:current_registration) { stub }
  before { controller.stub(:current_registration).and_return(current_registration) }

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
