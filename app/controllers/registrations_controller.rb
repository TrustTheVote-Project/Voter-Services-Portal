class RegistrationsController < ApplicationController

  def show
    @registration = current_registration
  end

end
