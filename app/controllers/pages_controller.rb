class PagesController < ApplicationController

  def front
    if AppConfig['no_forms']
      redirect_to :search
      return
    end
  end

end
