require 'spec_helper'

describe PagesController do

  describe 'front' do
    before { get :front }
    it     { should render_template :front }
  end

end
