Sidekiq.configure_server do |config|
  config.redis = { size: 2 }
end

Sidekiq.configure_client do |config|
  config.redis = { size: 1 }
end
