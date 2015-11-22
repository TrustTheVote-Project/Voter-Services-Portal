def load_config(name)
  config = YAML.load_file(File.join(Rails.root, 'config', name))
  env_config = config.delete(Rails.env)
  config.merge!(env_config) unless env_config.nil?
  config
end

AppConfig       = load_config('config.yml')
service_config  = load_config('config_service.yml')
timely_config   = load_config('config_timely.yml')
config_ovr   = load_config('config_ovr.yml')

AppConfig.merge!(timely_config) unless timely_config.nil?
AppConfig.merge!({ 'private' => service_config }) unless service_config.nil?
AppConfig.merge!({ 'OVR' => config_ovr }) unless config_ovr.nil?
