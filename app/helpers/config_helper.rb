module ConfigHelper

  def eligibility_config
    AppConfig['OVR']['eligibility']
  end

  ### Eligibility section helpers
  def default_eligibility_config?
    !eligibility_config['enable_method_virginia']
  end
  
  def is_complex_eligibility_requirement?(requirement_key)
    I18n.t("eligibility.requirements.#{requirement_key}").is_a?(Hash)
  end
  
  
  ### Optional questions section helpers

  def any_options?(updating)
    AppConfig['OVR']['enable_need_assistance_option'] || AppConfig['OVR']['enable_volunteer_option'] || (updating && AppConfig['OVR']['enable_absentee_option_domestic_update']) || (!updating && AppConfig['OVR']['enable_absentee_option_domestic_new'])
  end




  def enabled_uocava_reg
    @enabled_uocava_reg ||= AppConfig['enable_uocava_new_registration']
  end

  def custom_css_link_tag(name)
    if v = AppConfig['customization'].try(:[], name)
      stylesheet_link_tag v, :media => 'all'
    end
  end

  def alternate_localizations
    unless AppConfig['SupportedLocalizations'].blank?
      AppConfig['SupportedLocalizations']
        .select {|l| l['code'] != I18n.locale.to_s }
        .map do |l|
          alt_url = params.merge({:locale => l['code']})
          { text: l['name'], url: alt_url }
        end
    else
      []
    end
  end
  
  def subfooter_links
    unless AppConfig['SubfooterLinks'].blank?
      AppConfig['SubfooterLinks'].map do |link|
        if link['url'].blank?
          Rails.logger.warn "No url provided for subfooter_link #{link}"
          next nil
        end
        link_text = link['text']
        unless link_text.is_a?(String)
          Rails.logger.warn "Unexpected text value for subfooter_link #{link['url']}: #{link_text}"
        end
        unless AppConfig['SupportedLocalizations'].blank?
          link_text = I18n.t(link_text)
        end
        { text: link_text, url: link['url'] }
      end.compact
    else
      []
    end
  end

end
