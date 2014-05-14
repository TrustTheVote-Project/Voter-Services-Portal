class Api::VoterReportingController < ActionController::Base

  def lookup
    render json: {}, status: :not_found
  end

end
