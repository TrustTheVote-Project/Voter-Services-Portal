class RegistrationsController < ApplicationController

  before_filter :requires_registration

  def show
    @registration = current_registration
  end

  def edit
    @registration = current_registration
  end

  def update
    @registration = current_registration
    unless @registration.update_attributes(params[:registration])
      redirect_to :edit_registration, alert: 'Please review your registration data and try again'
    end
  end
end
