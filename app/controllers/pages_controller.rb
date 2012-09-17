class PagesController < ApplicationController

  def front
    if no_forms?
      redirect_to :search
      return
    end
  end

end
