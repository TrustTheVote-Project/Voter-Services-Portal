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

end
