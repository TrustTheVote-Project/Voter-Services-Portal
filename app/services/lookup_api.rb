require 'net/http'

class LookupApi

  class SearchError < StandardError
    attr_reader :title

    def initialize(key, fatal = false)
      super I18n.t("search.#{key}.body")
      @fatal = fatal
      @title = I18n.t("search.#{key}.title")
    end

    def can_retry?
      !@fatal
    end
  end

  # Raised when no record was found
  class RecordNotFound < SearchError
    def initialize
      super 'record_not_found'
    end
  end

  # Lookup times out
  class LookupTimeout < SearchError
    def initialize
      super 'timeout', true
    end
  end

  # Confidential record found
  class RecordIsConfidential < SearchError
    def initialize
      super 'record_is_confidential', true
    end
  end

  # Inactive record found
  class RecordIsInactive < SearchError
    def initialize
      super 'record_is_inactive', true
    end
  end

  def self.parse_uri(method, q)
    uri = URI("#{AppConfig['lookup_url']}/#{method}?#{q.to_query}")
    Rails.logger.info "Lookup URL: #{uri}"

    parse_uri_without_timeout(method, uri)
  rescue Timeout::Error
    ErrorLogRecord.log("Lookup: timeout", uri: uri)
    LogRecord.lookup_timeout(uri)

    raise LookupTimeout
  end

  def self.parse_uri_without_timeout(method, uri)
    req = Net::HTTP::Get.new(uri.request_uri)
    res = Net::HTTP.start(uri.hostname, uri.port,
                          use_ssl:      uri.scheme == 'https',
                          open_timeout: 5,
                          read_timeout: 15,
                          verify_mode:  OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(req)
    end

    handle_response(res, method)
  end

  # actual parsing of the response
  def self.handle_response(res, method = nil)
    raise "implement"
  end

end
