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

end
