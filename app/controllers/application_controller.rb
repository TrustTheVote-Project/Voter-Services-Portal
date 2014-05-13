class ApplicationController < ActionController::Base

  protect_from_forgery

  before_filter :set_env_vars

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
    gon.enable_dmvid_lookup           = AppConfig['enable_dmvid_lookup']
    gon.enable_dmv_address_display    = AppConfig['enable_dmv_address_display']
    gon.personal_data_on_eligibility_page = AppConfig['personal_data_on_eligibility_page']
    gon.require_dmv_id                = AppConfig['require_dmv_id']
    gon.enable_dmv_ovr                = AppConfig['enable_dmv_ovr']
    gon.enable_expanded_felony_mental_eligibility = AppConfig['enable_expanded_felony_mental_eligibility']
    gon.state_id_length_min           = AppConfig['state_id_length']['min']
    gon.state_id_length_max           = AppConfig['state_id_length']['max']

    gon.i18n_dmvid                    = I18n.t('dmvid')
    gon.i18n_confirm_not_provided     = I18n.t("confirm.not_provided")
    gon.i18n_confirm_required         = I18n.t("confirm.required")
    gon.i18n_confirm_not_required     = I18n.t("confirm.not_required")
    gon.i18n_confirm_prev_reg_not_reg = I18n.t("confirm.previous_registration.not_registered")
  end

end
