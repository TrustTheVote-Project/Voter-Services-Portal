module ConfigHelper

  def eligibility_config
    AppConfig['OVR']['eligibility']
  end

  def identity_config
    AppConfig['OVR']['identity']
  end
  
  def address_config
    AppConfig['OVR']['address']
  end
  
  def option_config
    AppConfig['OVR']['options']
  end
  
  def completion_config
    AppConfig['OVR']['completion']
  end
  
  ### Eligibility section helpers
  def default_eligibility_config?
    !eligibility_config['enable_method_virginia']
  end
  
  def is_complex_eligibility_requirement?(requirement_key)
    I18n.t("eligibility.requirements.#{requirement_key}").is_a?(Hash)
  end

  
  ### Identity section helpers
  def default_identity_name_config?
    !identity_config['enable_names_virginia']
  end
  
  def identity_field_enabled?(field)
    identity_config["enable_#{field}"]
  end
  
  def identity_field_required?(field)
    identity_config["require_#{field}"]
  end
  
  def identity_field_options(field)
    identity_config["#{field}_options"].collect {|k| [I18n.t("identity.#{field}_options.#{k}"), k]}
  end
  
  def identity_name_fields
    possible_name_fields = [:name_prefix,
    :first_name,
    :middle_name,
    :last_name,
    :name_suffix]
    name_fields = []
    possible_name_fields.each do |f|
      if identity_config["enable_#{f}"]
        field = {name: f, required: identity_config["require_#{f}"]}        
        name_fields << field
      end
    end
    name_fields
  end
  
  
  
  ### Optional questions section helpers

  def any_options?(updating)
    option_config['enable_need_assistance'] || option_config['enable_volunteer'] || (updating && option_config['enable_absentee_domestic_update']) || (!updating && option_config['enable_absentee_domestic_new'])
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
