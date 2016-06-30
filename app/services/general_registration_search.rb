class GeneralRegistrationSearch

  def self.perform(search_query, config)
    q = {} # todo search_query -> URL params
    uri = URI("#{config['url']}?#{q.to_query}")
    result = nil

    begin
      raise 'generic lookup service is not configured' if config['url'].blank?

      LookupApi.parse_uri_without_timeout('not_used_method_name', uri) do |response|
        if response.code == '200'
          result = JSON.parse(response.body)
        else
          raise LookupApi::SearchError.new('timeout') # TODO locale key to show others errors
        end
      end
    rescue Timeout::Error
      Rails.logger.error "LOOKUP: timeout URL: #{uri}" if AppConfig['api_debug_logging']
      ErrorLogRecord.log("LOOKUP: timeout", uri: uri)
      LogRecord.lookup_timeout(uri)

      raise LookupApi::LookupTimeout
    end

    VriAdapter.new(result).to_registration
  end
end
