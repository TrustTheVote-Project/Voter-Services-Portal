class RegistrationRequestsController < ApplicationController

  def new
    LogRecord.log('registration', 'started')
    @registration_request = RegistrationRequest.new
    @registration_request.build_virginia_voting_address
    @registration_request.build_mailing_address
  end

  def create
    # TODO implement saving data, generation of PDF etc
    flash[:notice] = 'Your registration data has been sent.'
    redirect_to :root
  end

end
