module ConfigHelper

  def enabled_uocava_reg
    @enabled_uocava_reg ||= AppConfig['enable_uocava_new_registration']
  end

end
