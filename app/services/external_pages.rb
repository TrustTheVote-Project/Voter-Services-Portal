require 'open-uri'

class ExternalPages

  # Fetches or looks up cached version of the page
  def self.get_by_name(name)
    get_from_cache(name) || cache(name, get_from_remote(name))
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
    page = name.gsub(/[^a-z_\-]/i, '')
    path = config[page]

    open("#{base}/#{path}").read.gsub(/(^.*<body[^>]*>|<\/body>.*$)/mi, '')
  end

  def self.cache(name, body)
    redis.setex(key(name), expiry_period, body)
  end

  def self.key(name)
    "ep.#{name}"
  end

  def self.redis
    @redis ||= Redis.new
  end

  def self.expiry_period
    1.day
  end

end
