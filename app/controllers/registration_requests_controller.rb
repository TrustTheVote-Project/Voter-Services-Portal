class RegistrationRequestsController < ApplicationController

  def new
    LogRecord.log('registration', 'started')
    @registration_request = RegistrationRequest.new
  end

  def create
    # TODO implement saving data, generation of PDF etc
    flash[:notice] = 'Your registration data has been sent.'
    redirect_to :root
  end

end
