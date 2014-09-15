module ConfigHelper

  def enabled_uocava_reg
    @enabled_uocava_reg ||= AppConfig['enable_uocava_new_registration']
  end

  def custom_css_link_tag(name)
    if v = AppConfig['customization'].try(:[], name)
      stylesheet_link_tag v, :media => 'all'
    end
  end

end
