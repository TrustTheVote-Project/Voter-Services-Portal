require 'spec_helper'

describe PagesController do

  describe 'front' do
    let!(:oldnf) { AppConfig['enable_forms'] }
    after { AppConfig['enable_forms'] = oldnf }

    context 'no forms' do
      before { AppConfig['enable_forms'] = false }
      before { get :front }
      it     { should redirect_to :search }
    end

    context 'with forms' do
      before { AppConfig['enable_forms'] = true }
      before { get :front }
      it     { should render_template :front }
    end
  end

  describe 'privacy' do
    it 'should render template w/ new reg path' do
      get :privacy, path: 'new_registration'
      should render_template :privacy
      assigns(:redirect_path).should == new_registration_path
    end

    it 'should render template w/ new reg path' do
      get :privacy, path: 'edit_registration'
      should render_template :privacy
      assigns(:redirect_path).should == edit_registration_path
    end

    it 'should render template w/ absentee request path' do
      get :privacy, path: 'request_absentee_registration'
      should render_template :privacy
      assigns(:redirect_path).should == request_absentee_registration_path
    end

    it 'should render template w/ residential reg path' do
      get :privacy, path: 'register_residential'
      should render_template :privacy
      assigns(:redirect_path).should == register_residential_path
    end

    it 'should render template w/ overseas reg path' do
      get :privacy, path: 'register_overseas'
      should render_template :privacy
      assigns(:redirect_path).should == register_overseas_path
    end
  end

end
