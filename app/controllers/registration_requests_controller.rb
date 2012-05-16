class RegistrationRequestsController < ApplicationController

  def new
    LogRecord.log('registration', 'started')
    @registration_request = RegistrationRequest.new(
      residence: params[:kind] == 'residential' ? 'in' : 'outside',
      absentee_until: 1.year.from_now.strftime('%m/%d/%Y') )
  end

  def create
    data = params[:registration_request]
    Converter.params_to_date(data,
      :vvr_uocava_residence_unavailable_since,
      :dob,
      :rights_restored_on)

    @registration_request = RegistrationRequest.new(data)

    if @registration_request.save
      session[:regreq_id] = @registration_request.id
      render :show
    else
      flash.now[:error] = 'Please review your request data and try submitting again'
      render :new
    end
  end

  def show
    @registration_request = last_registration_request
    respond_to do |f|
      f.html
      f.pdf  { render layout: false }
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :new_registration_request
  end

  private

  def last_registration_request
    RegistrationRequest.find(session[:regreq_id])
  end

end
