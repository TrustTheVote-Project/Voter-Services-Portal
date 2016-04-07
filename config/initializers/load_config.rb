def load_config(name)
  file_name = File.join(Rails.root, 'config', name)
  return nil if !File.exists?(file_name)
  config = YAML.load_file(file_name)
  return nil if !config.is_a?(Hash)
  env_config = config.delete(Rails.env)
  config.deep_merge!(env_config) unless env_config.nil?
  config
end

AppConfig       = load_config('config.yml')
if custom = ENV['SAMPLE_DEPLOY_TARGET']
  custom_app_config = load_config("config.yml.#{custom}sample")
  AppConfig.deep_merge!(custom_app_config) unless custom_app_config.nil?
end

service_config  = load_config('config_service.yml')
if custom
  custom_service_config = load_config("config_service.yml.#{custom}sample")
  service_config.deep_merge!(custom_service_config) unless custom_service_config.nil?
end

timely_config   = load_config('config_timely.yml')
if custom
  custom_timely_config = load_config("config_timely.yml.#{custom}sample")
  timely_config.deep_merge!(custom_timely_config) unless custom_timely_config.nil?
end

config_ovr   = load_config('config_ovr.yml')
if custom
  custom_config_ovr = load_config("config_ovr.yml.#{custom}sample")
  config_ovr.deep_merge!(custom_config_ovr) unless custom_config_ovr.nil?
end

AppConfig.deep_merge!(timely_config) unless timely_config.nil?
AppConfig.deep_merge!({ 'private' => service_config }) unless service_config.nil?
AppConfig.deep_merge!({ 'OVR' => config_ovr }) unless config_ovr.nil?
