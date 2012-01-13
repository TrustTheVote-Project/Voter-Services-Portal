class PagesController < ApplicationController

  def front
    @search_query ||= SearchQuery.new
    render :front
  end

  def search
    @search_query = SearchQuery.new(params[:search_query])
    unless @search_query.valid?
      flash[:error] = "Form is incomplete."
      return front
    end

    reg = RegistrationSearch.perform(@search_query)

    if reg
      # TODO store it locally to be available through #current_registration method
      redirect_to :found
    else
      redirect_to :not_found
    end
  end

end
