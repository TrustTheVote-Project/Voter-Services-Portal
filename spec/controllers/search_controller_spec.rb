require 'spec_helper'

describe SearchController do

  let(:q) { { locality: 'A', voter_id: 'B' } }
  let(:r) { FactoryGirl.create(:existing_residential_voter) }

  describe 'search' do
    context 'invalid search query' do
      before  { SearchQuery.any_instance.should_receive(:valid?).and_return(false) }
      before  { post :create, search_query: q }
      it      { should render_template :new }
    end

    context 'search without error' do
      before  { RegistrationSearch.should_receive(:perform).and_return(r) }
      before  { LogRecord.should_receive(:log) }
      before  { post :create, search_query: q }
      it      { should redirect_to :registration }
    end

    context 'search with record not found error' do
      before  { RegistrationSearch.should_receive(:perform).and_raise(RegistrationSearch::RecordNotFound) }
      before  { LogRecord.should_receive(:log) }
      before  { post :create, search_query: q }
      specify { assigns(:error).should be }
      it      { should render_template :error }
    end

    context 'search with any other error' do
      before  { RegistrationSearch.should_receive(:perform).and_raise(RegistrationSearch::RecordIsConfidential) }
      before  { LogRecord.should_not_receive(:log) }
      before  { post :create, search_query: q }
      specify { assigns(:error).should be }
      it      { should render_template :error }
    end
  end

end
