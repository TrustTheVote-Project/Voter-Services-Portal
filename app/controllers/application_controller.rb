class ApplicationController < ActionController::Base

  protect_from_forgery

  # Returns the registration record for the current session
  def current_registration
    @current_registration ||= RegistrationRepository.get_registration(session[:session_id])
  end

end
