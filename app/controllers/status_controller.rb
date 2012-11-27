class StatusController < ApplicationController

  layout 'mobile'

  # shows the status
  def show
    @registration = RegistrationRepository.get_registration(session)
    if @registration.present?
      @search_query = SearchQuery.new
      render :show
    else
      search_form
    end
  end

  # renders the search form
  def search_form
    @search_query ||= SearchQuery.new(params[:search_query])
    @search_query.lookup_type = 'vid'
    render :show
  end

  # searches for the record and shows status
  def search
    @search_query = SearchQuery.new(params[:search_query])
    return search_form unless @search_query.valid?

    @registration = RegistrationSearch.perform(@search_query)
    RegistrationRepository.store_registration(session, @registration)

    render :show
  rescue RegistrationSearch::SearchError => @error
    search_form
  end

end
