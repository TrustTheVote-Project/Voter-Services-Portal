module ConfigHelper

  def ovr_config
    AppConfig['OVR']
  end

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
  
  def services_config
    AppConfig['services']
  end
  
  def lookup_service_config
    services_config['lookup']
  end
  def registration_service_config
    services_config['registration']
  end
  
  
  ### Lookup section helpers
  def lookup_service_field_options(field)
    lookup_service_config["#{field}_options"].collect {|k| [I18n.t("search.#{field}_options.#{k}"), k]}
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

  # Array of links to current page with alternate supported localizations.
  # Will return empty array if SupportedLocalizations config is empty or has
  # only one localization.
  def alternate_localization_links
    AppConfig.fetch('SupportedLocalizations', [])
      .select {|l| l['code'] != I18n.locale.to_s }
      .map do |l|
        alt_url = params.merge({:locale => l['code']})
        { 'text' => l['text'], 'url' => alt_url }
    end
  end

  # Generates a list of links from a Hash with 'url' and 'text'
  # keys.
  # For use with the HeaderLinks and SubfooterLinks config keys,
  # and the output of alternate_localization_links.
  def generate_link_list(links_spec)
    unless links_spec.blank?
      links_spec.map do |link|
        link_url = link['url']
        link_text_key = link['text']
        if link_url.nil?
          Rails.logger.warn "Missing url for link #{link}"
          next nil
        elsif !link_url.is_a?(String) && !link_url.is_a?(Hash)
          Rails.logger.warn "Invalid url provided for link #{link}: #{link_url} (#{link_url.class}), must be a String or Hash"
          next nil
        elsif link_text_key.blank?
          Rails.logger.warn "Missing text for link #{link}"
          next nil
        elsif !link_text_key.is_a?(String)
          Rails.logger.warn "Invalid text for link #{link}: #{link_text_key} (#{link_text_key.class}), must be a String"
          next nil
        end

        link_text = I18n.t(link_text_key)
        if link_url.is_a?(String)
          link_to link_text, File.join("/", I18n.locale.to_s, link_url.to_s)
        else
          link_to link_text, link_url
        end
      end.compact.join('&nbsp;&nbsp;|&nbsp;&nbsp;')
    end
  end

end
