class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :set_env_vars

  before_filter :set_locale

  # Returns the registration record for the current session
  def current_registration
    @current_registration ||= RegistrationRepository.get_registration(session)
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
    gon.enable_dmvid_lookup           = AppConfig['OVR']['Eligibility']['PreCheckForPaperless']
    gon.enable_dmv_address_display    = AppConfig['OVR']['enable_dmv_address_display']
    gon.eligibility_single_statement  = AppConfig['OVR']['Eligibility']['SingleStatement']
    gon.personal_data_on_eligibility_page = AppConfig['OVR']['personal_data_on_eligibility_page']
    gon.require_dmv_id                = AppConfig['OVR']['require_dmv_id']
    gon.enable_dmv_ovr                = AppConfig['enable_dmv_ovr']
    gon.enable_expanded_felony_mental_eligibility = AppConfig['OVR']['enable_expanded_felony_mental_eligibility']
    gon.state_id_length_min           = AppConfig['OVR']['state_id_length']['min']
    gon.state_id_length_max           = AppConfig['OVR']['state_id_length']['max']

    gon.i18n_dmvid                    = I18n.t('dmvid')
    gon.i18n_confirm_not_provided     = I18n.t("confirm.not_provided")
    gon.i18n_confirm_required         = I18n.t("confirm.required")
    gon.i18n_confirm_not_required     = I18n.t("confirm.not_required")
    gon.i18n_confirm_prev_reg_not_reg = I18n.t("confirm.previous_registration.not_registered")
  end

  def default_url_options(options = {})
    if AppConfig['supported_localizations'].any?
      { locale: I18n.locale }.merge options
    else
      {}
    end
  end

  def set_locale
    if AppConfig['supported_localizations'].any?
      default_locale = AppConfig['supported_localizations'].map {|l| l['code'] }.first
      I18n.locale = params[:locale] || default_locale || I18n.default_locale
    end
  end

end
