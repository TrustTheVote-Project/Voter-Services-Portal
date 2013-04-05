class RegistrationsController < ApplicationController

  before_filter :requires_registration, except: [ :new, :create ]

  def new
    if no_forms?
      redirect_to :about_registration_page
      return
    end

    options = RegistrationRepository.pop_search_query(session)
    options.merge!(
      residence:            params[:residence],
      requesting_absentee:  params[:residence] == 'outside' ? '1' : '0')

    # remove unrelated fields
    options.delete(:lookup_type)
    options.delete(:locality)

    @registration = Registration.new(options)
    @registration.init_absentee_until

    log_record = LogRecord.start_new(@registration)

    # Remember this record id as we may need to update it later
    session[:slr_id] = log_record.id

    ActiveForm.mark!(session, @registration)
  end

  def create
    active_form = ActiveForm.find_for_session!(session)

    data = params[:registration]
    Converter.params_to_date(data, :vvr_uocava_residence_unavailable_since, :dob, :absentee_until, :rights_restored_on)
    Converter.params_to_time(data, :ab_time_1, :ab_time_2)
    @registration = Registration.new(data)

    if @registration.save
      SubmitEml310.schedule(@registration)

      active_form.unmark!

      # Lod completion
      LogRecord.complete_new(@registration, session[:slr_id])
      session[:slr_id] = nil

      RegistrationRepository.store_registration(session, @registration)
      render :show
    else
      active_form.touch
      flash.now[:error] = 'Please review your request data and try submitting again'
      render :new
    end
  rescue ActiveForm::Expired
    render :expired
  end

  def show
    @registration = current_registration
    @update       = !@registration.previous_data.blank?

    # Disallow rendering of PDF and EML310 in no-forms version
    return if no_forms?

    respond_to do |f|
      f.html

      f.pdf do
        doctype = 'VoterRegistrationRequest'

        if @update
          doctype = @registration.requesting_absentee == '1' ? 'VoterRecordnUpdateAbsenteeRequest' : 'VoterRecordUpdate'
        end

        LogRecord.log(doctype, 'complete', @registration)

        # Doing it in such a weird way because of someone stealing render / render_to_string method from wicked_pdf
        render text: WickedPdf.new.pdf_from_string(
          render_to_string(template: 'registrations/pdf/show', pdf: 'registration.pdf', layout: 'pdf'),
          margin: { top: 5, right: 5, bottom: 5, left: 5 })
      end

      # EML310 debug rendering is enabled only in development
      if Rails.env.development?
        f.xml do
          render 'registrations/eml310/show', layout: false
        end
      end
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to :root
  end

  def edit
    @registration = current_registration

    record = LogRecord.start_update(@registration)
    session[:slr_id] = record.id

    ActiveForm.mark!(session, @registration)

    # "kind" comes from the review form where we either maintain or
    # change the status.
    @registration.init_update_to(params[:kind].to_s)

    # Take SSN4 from the stored lookup data if it's not there
    ssn4 = RegistrationRepository.get_lookup_ssn4(session)
    @registration.ssn4 = ssn4 if @registration.ssn4.blank?
  end

  def update
    active_form = ActiveForm.find_for_session!(session)

    data = params[:registration]
    Converter.params_to_date(data, :vvr_uocava_residence_unavailable_since, :dob, :absentee_until, :rights_restored_on)
    Converter.params_to_time(data, :ab_time_1, :ab_time_2)

    @registration = current_registration
    @registration.init_update_to(params[:kind])

    lookup_data = RegistrationRepository.pop_lookup_data(session)
    @registration.dob = lookup_data[:dob]

    unless @registration.update_attributes(data)
      active_form.touch
      redirect_to :edit_registration, alert: 'Please review your registration data and try again'
    else
      SubmitEml310.schedule(@registration)

      active_form.unmark!

      LogRecord.complete_update(@registration, session[:slr_id])
      session[:slr_id] = nil
    end
  rescue ActiveForm::Expired
    render :expired
  end

end
