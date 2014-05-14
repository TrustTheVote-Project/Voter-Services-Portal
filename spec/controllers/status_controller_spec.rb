require 'spec_helper'

describe StatusController do

  let(:r) { FactoryGirl.build(:existing_residential_voter) }

  describe 'show' do
    it 'should render the search form if there is no registration to display' do
      get :show
      assigns(:search_query).should be
      should render_template :show
    end

    it 'should render the registration data' do
      expect(RegistrationRepository).to receive(:get_registration).and_return(r)
      get :show
      assigns(:search_query).should be
      assigns(:registration).should == r
      should render_template :show
    end
  end

  describe 'search' do
    it 'should render the search form if query is invalid' do
      post :search
      assigns(:search_query).should be
      should render_template :show
    end

    it 'should render the registration data upon successful search' do
      expect(RegistrationSearch).to receive(:perform).and_return(r)
      post :search, search_query: { voter_id: '600000000', locality: 'NORFOLK CITY' }
      assigns(:search_query).should be
      assigns(:registration).should == r
      should render_template :show
    end

    it 'should render the error page on error' do
      allow_any_instance_of(SearchQuery).to receive(:valid?).and_return(true)
      expect(RegistrationSearch).to receive(:perform).and_raise(RegistrationSearch::RecordNotFound)
      post :search
      assigns(:search_query).should be
      assigns(:error).should be
      should render_template :show
    end
  end

end
