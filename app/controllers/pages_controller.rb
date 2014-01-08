class PagesController < ApplicationController

  def front
    if no_forms?
      redirect_to :search
      return
    end
  end

  def demo_splash
    render :demo_splash, layout: false
  end

  def security
    @page = 'security_privacy'
    render :external_page
  end

  def online_ballot_marking
    @page = 'online_ballot_marking'
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
