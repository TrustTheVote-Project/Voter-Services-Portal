module ConfigHelper

  def enabled_uocava_reg
    @enabled_uocava_reg ||= AppConfig['enable_uocava_new_registration']
  end

  def custom_css_link_tag(name)
    if v = AppConfig['customization'].try(:[], name)
      stylesheet_link_tag v, :media => 'all'
    end
  end

  def alternate_localizations
    if AppConfig['supported_localizations'].any?
      AppConfig['supported_localizations']
        .select {|l| l['code'] != I18n.locale.to_s }
        .map do |l|
          alt_url = params.merge({:locale => l['code']})
          { text: l['name'], url: alt_url }
        end
    else
      []
    end
  end

end
