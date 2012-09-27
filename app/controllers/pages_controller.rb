class PagesController < ApplicationController

  def front
    if no_forms?
      redirect_to :search
      return
    end
  end

  def method_missing(name, *args)
    @page = name
    render :external_page
  end

end
