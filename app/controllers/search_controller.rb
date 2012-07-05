# Registration search
class SearchController < ApplicationController

  def new
    @search_query ||= SearchQuery.new
    render :new
  end

  def create
    @search_query = SearchQuery.new(params[:search_query])
    unless @search_query.valid?
      flash[:error] = "Form is incomplete."
      return new
    end

    reg = RegistrationSearch.perform(@search_query)

    if reg
      LogRecord.log("", "identify", reg.voter_id, "Match for #{@search_query.to_log_details}")
      RegistrationRepository.store_registration(session, reg)
      redirect_to :registration
    else
      LogRecord.log("", "identify", reg.voter_id, "No match for #{@search_query.to_log_details}")
      RegistrationRepository.store_search_query(session, @search_query)
      render :not_found
    end
  end

end
