class LookupController < ApplicationController

  def registration
    render json: LookupService.registration(params[:record].symbolize_keys)
  end

end
