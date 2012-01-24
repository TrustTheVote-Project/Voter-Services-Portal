class RegistrationsController < ApplicationController

  def show
    @registration = current_registration
  end

  def new
    LogRecord.log('registration', 'started')
  end

end
