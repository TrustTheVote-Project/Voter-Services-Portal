require 'open-uri'

class ExternalPages

  # Fetches or looks up cached version of the page
  def self.get_by_name(name)
    (get_from_cache(name) || cache(name, get_from_remote(name))).to_s.html_safe
  end

  # Resets the cache
  def self.reset_cache
    redis.keys(key('*')).each do |k|
      redis.del(k)
    end
  end

  private

  def self.get_from_cache(name)
    redis.get(key(name))
  end

  def self.get_from_remote(name)
    config = AppConfig['static_pages']
    base = config['url_base']
    page = name.to_s.gsub(/[^a-z_\-]/i, '')

    unless config.has_key? page
      Rails.logger.warn "STATIC PAGE: missing config key for #{page}"
    end

    path = config[page]

    if AppConfig['supported_localizations'] && AppConfig['supported_localizations'].any?
      full_path = "#{base}/#{I18n.locale}/#{path}"
    else
      full_path = "#{base}/#{path}"
    end

    Rails.logger.debug "STATIC PAGE: #{full_path}"

    res = open("#{full_path}").read.gsub(/(^.*<body[^>]*>|<\/body>.*$)/mi, '')
    res
  end

  def self.cache(name, body)
    redis.setex(key(name), expiry_period, body)
    body
  end

  def self.key(name)
    if AppConfig['supported_localizations'] && AppConfig['supported_localizations'].any?
      "ep.#{name}.#{I18n.locale}"
    else
      "ep.#{name}"
    end
  end

  def self.redis
    @redis ||= Redis.new
  end

  def self.expiry_period
    Rails.env.development? ? 5.seconds : 1.day
  end

end
