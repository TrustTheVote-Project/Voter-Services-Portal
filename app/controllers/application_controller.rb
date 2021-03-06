class ApplicationController < ActionController::Base
  include ConfigHelper
  
  rescue_from ActionController::RoutingError, :with => :render_not_found
  
  protect_from_forgery

  before_filter :set_env_vars

  before_filter :set_locale

  # Returns the registration record for the current session
  def current_registration
    @current_registration ||= RegistrationRepository.get_registration(session)
  end

  def render_not_found(e)
    @page = 'four_oh_four'
    render 'pages/external_page', status: 404
  end
  
  def raise_not_found!
    raise ActionController::RoutingError.new("No route matches #{params[:unmatched_route]}")
  end
  
  
  protected

  # TRUE when forms are disabled
  def no_forms?
    !AppConfig['enable_forms']
  end
  helper_method :no_forms?

  # Filter that makes sure there's a registration object
  # available, otherwise redirects to the front page.
  def requires_registration
    redirect_to :root unless current_registration
  end

  def set_env_vars
    gon.locale = I18n.locale
    gon.enable_dmvid_lookup           = eligibility_config['check_for_paperless_eligibility']
    gon.enable_dmv_address_display    = AppConfig['OVR']['enable_dmv_address_display']
    gon.eligibility_with_identity     = eligibility_config['combine_with_identity']
    gon.default_eligibility_config    = default_eligibility_config?
    gon.default_identity_name_config    = default_identity_name_config?
    gon.enable_names_virginia         = identity_config['enable_names_virginia']
    gon.personal_data_on_eligibility_page = AppConfig['OVR']['eligibility']['CollectPersonalData'] && !eligibility_config['combine_with_identity']
    gon.require_transport_id_number                = eligibility_config['require_transport_id_number']
    gon.enable_lookup_service         = lookup_service_config['enabled']
    gon.lookup_service_config         = lookup_service_config
    gon.enable_digital_ovr                = AppConfig['OVR']['EnableDigitalService']
    gon.enable_paper_ovr                = AppConfig['OVR']['EnablePaperService']
    gon.enable_expanded_felony_mental_eligibility = AppConfig['OVR']['enable_expanded_felony_mental_eligibility']
    gon.state_id_length_min           = AppConfig['OVR']['state_id_length']['min']
    gon.state_id_length_max           = AppConfig['OVR']['state_id_length']['max']
    gon.virginia_absentee             = option_config['virginia_absentee']
    gon.virginia_address              = address_config['virginia_address']
    gon.us_format                     = address_config['us_format']
    gon.canada_format                 = address_config['canada_format']
    gon.default_state                 = address_config['explicit_state']
    gon.enable_previous_registration  = address_config['enable_previous_registration']
    gon.i18n_dmvid                    = I18n.t('dmvid')
    gon.i18n_id_documentation_image   = I18n.t('identity.id_documentation_image')
    gon.i18n_confirm_not_provided     = I18n.t("confirm.not_provided")
    gon.i18n_confirm_required         = I18n.t("confirm.required")
    gon.i18n_confirm_not_required     = I18n.t("confirm.not_required")
    gon.i18n_confirm_prev_reg_not_reg = I18n.t("confirm.previous_registration.not_registered")
    gon.date_format = prepare_js_date_format
  end

  def default_url_options(options = {})
    unless AppConfig['SupportedLocalizations'].blank?
      { locale: I18n.locale }.merge options
    else
      {}
    end
  end

  def set_locale
    unless AppConfig['SupportedLocalizations'].blank?
      default_locale = AppConfig['SupportedLocalizations'].map {|l| l['code'] }.first
      I18n.locale = params[:locale] || default_locale || I18n.default_locale
    end
  end
  
  def prepare_js_date_format
    format = AppConfig['date_format'] || 'MMDDYYYY'
    format = 'MMDDYYYY' if format.length != 8 || !format.include?('YYYY')|| !format.include?('MM')|| !format.include?('DD')
    format = format.sub('DD', 'DDDD')
    format = format.sub('MM', 'MMMM')
    format = [format[0..3], format[4..7], format[8..11]].join(' ')
    format = format.sub('DDDD', 'D')
    # "YYYY, MMMM D
    format.sub!('YYYY', 'YYYY,') if format.starts_with? 'YYYY'
    # "MMMM D, YYYY
    format.sub!(' YYYY', ', YYYY') if format.ends_with? ' YYYY'
    format
  end

end
