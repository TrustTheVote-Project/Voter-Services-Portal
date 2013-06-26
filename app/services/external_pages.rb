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
    path = config[page]

    Rails.logger.debug "STATIC PAGE: #{base}/#{path}"

    res = open("#{base}/#{path}").read.gsub(/(^.*<body[^>]*>|<\/body>.*$)/mi, '')
    res
  end

  def self.cache(name, body)
    redis.setex(key(name), expiry_period, body)
    body
  end

  def self.key(name)
    "ep.#{name}"
  end

  def self.redis
    @redis ||= Redis.new
  end

  def self.expiry_period
    Rails.env.development? ? 5.seconds : 1.day
  end

end
