class PagesController < ApplicationController

  def front
    if no_forms?
      redirect_to :search
      return
    end
  end

  def security
    @page = 'security-privacy'
    render :external_page
  end

  def online_ballot_marking
    @page = 'online-ballot-marking'
    render :external_page
  end

  def privacy
    @redirect_path = send("#{params[:path]}_path")
  end

  def method_missing(name, *args)
    @page = name
    render :external_page
  end

end
