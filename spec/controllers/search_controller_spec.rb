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
  end

end
