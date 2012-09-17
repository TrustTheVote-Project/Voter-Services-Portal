class ApplicationController < ActionController::Base

  protect_from_forgery

  # Returns the registration record for the current session
  def current_registration
    @current_registration ||= RegistrationRepository.get_registration(session)
  end

  protected

  # TRUE when forms are disabled
  def no_forms?
    AppConfig['no_forms']
  end
  helper_method :no_forms?

  # Filter that makes sure there's a registration object
  # available, otherwise redirects to the front page.
  def requires_registration
    redirect_to :root unless current_registration
  end

end
