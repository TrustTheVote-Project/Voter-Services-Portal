class RegistrationRequestsController < ApplicationController

  def new
    LogRecord.log('registration', 'started')
    @registration_request = RegistrationRequest.new
  end

  def create
    data = params[:registration_request]
    Converter.params_to_date(data,
      :vvr_uocava_residence_unavailable_since,
      :dob,
      :convicted_rights_restored_on,
      :mental_rights_restored_on)

    puts data.inspect

    @registration_request = RegistrationRequest.create(data)
    render :return_application
  end

end
