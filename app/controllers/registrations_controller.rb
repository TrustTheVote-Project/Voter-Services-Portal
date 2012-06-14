class RegistrationsController < ApplicationController

  before_filter :requires_registration

  def show
    @registration = current_registration
  end

  def edit
    @registration = current_registration
  end

end
