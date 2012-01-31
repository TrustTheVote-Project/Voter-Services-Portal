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
      RegistrationRepository.store_registration(session, reg)
      redirect_to :registration
    else
      render :not_found
    end
  end

end
