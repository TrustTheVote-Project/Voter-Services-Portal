require 'spec_helper'

describe PagesController do

  describe 'front' do
    let!(:oldnf) { AppConfig['no_forms'] }
    after { AppConfig['no_forms'] = oldnf }

    context 'no forms' do
      before { AppConfig['no_forms'] = true }
      before { get :front }
      it     { should redirect_to :search }
    end

    context 'with forms' do
      before { AppConfig['no_forms'] = false }
      before { get :front }
      it     { should render_template :front }
    end
  end

  describe 'privacy' do
    it 'should render template w/ search path' do
      get :privacy, path: 'search_form'
      should render_template :privacy
      assigns(:redirect_path).should == search_form_path
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
