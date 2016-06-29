require 'spec_helper'

describe SearchController do

  let(:q) { { locality: 'A', voter_id: 'B' } }
  let(:r) { FactoryGirl.create(:existing_residential_voter) }

  describe 'search' do
    context 'invalid search query' do
      before  { expect_any_instance_of(SearchQuery).to receive(:valid?).and_return(false) }
      before  { post :create, search_query: q }
      it      { should render_template :new }
    end

    context 'search without error' do
      before  { expect(RegistrationSearch).to receive(:perform).and_return(r) }
      before  { expect(LogRecord).to receive(:identify).with(r, 'A') }
      before  { post :create, search_query: q }
      it      { should redirect_to :registration }
    end

    context 'search with record not found error' do
      before  { expect(RegistrationSearch).to receive(:perform).and_raise(RegistrationSearch::RecordNotFound) }
      before  { post :create, search_query: q }
      specify { assigns(:error).should be }
      it      { should render_template :error }
    end

    context 'search with any other error' do
      before  { expect(RegistrationSearch).to receive(:perform).and_raise(RegistrationSearch::RecordIsConfidential) }
      before  { post :create, search_query: q }
      specify { assigns(:error).should be }
      it      { should render_template :error }
    end

    context 'general search is set up' do
      it 'invokes General Search' do
        # can't fix SearchQuery conditional attributes, only one custom env can be set when classes are loaded
        # so we fix consequences - valid? is always true
        expect_any_instance_of(SearchQuery).to receive(:valid?).and_return(true)
        expect(GeneralRegistrationSearch).to receive(:perform).and_return(FactoryGirl.create(:registration, :residential_voter))

        # system PARTLY works right only if expected values are loaded from the config
        # can't mock this due to SearchQuery design
        expect(AppConfig['services']['lookup']['id_and_locality_style']).to be_false

        post :create, locale: 'en', search_query: {
            "first_name"=>"a",
            "last_name"=>"a",
            "street_number"=>"1",
            "street_name"=>"main",
            "street_type"=>"Street",
            "date_of_birth"=>Date.new(1990,1,1)
        }
      end
    end
  end

end
