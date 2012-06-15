class RegistrationsController < ApplicationController

  before_filter :requires_registration

  def new
    LogRecord.log('registration', 'started')
    @registration = Registration.new(
      residence:      params[:kind] == 'residential' ? 'in' : 'outside',
      absentee_until: 1.year.from_now)
  end

  def create
    data = params[:registration]
    Converter.params_to_date(data,
      :vvr_uocava_residence_unavailable_since,
      :dob,
      :absentee_until,
      :rights_restored_on)

    @registration = Registration.new(data)

    if @registration.save
      RegistrationRepository.store_registration(session, @registration)
      render :show
    else
      flash.now[:error] = 'Please review your request data and try submitting again'
      render :new
    end
  end

  def show
    @registration = current_registration
    respond_to do |f|
      f.html
      f.pdf  { render layout: false }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :root
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
