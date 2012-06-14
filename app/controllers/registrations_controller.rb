class RegistrationsController < ApplicationController

  def show
    @registration = current_registration
  end

  def edit
    @registration = current_registration
  end

end
