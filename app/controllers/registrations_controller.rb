class RegistrationsController < ApplicationController

  def show
    @registration = current_registration
  end

  def new
    LogRecord.log('registration', 'started')

    @registration = Registration.new
  end

end
