# Registration search
class SearchController < ApplicationController

  def new
    options = RegistrationRepository.pop_search_query(session)
    @search_query ||= SearchQuery.new(options)
    render :new
  end

  def create
    @search_query = SearchQuery.new(params[:search_query])
    return new unless @search_query.valid?

    reg = RegistrationSearch.perform(@search_query)

    LogRecord.log("", "identify", reg, "Match for #{@search_query.to_log_details}")
    RegistrationRepository.store_registration(session, reg)

    redirect_to :registration
  rescue RegistrationSearch::SearchError => @error
    if @error.kind_of? RegistrationSearch::RecordNotFound
      LogRecord.log("", "identify", nil, "No match for #{@search_query.to_log_details}")
    end

    RegistrationRepository.store_search_query(session, @search_query)

    render :error
  end

end
