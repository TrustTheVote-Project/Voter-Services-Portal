class GeneralRegistrationSearch

  def self.perform(search_query, config)
    q = { first_name: search_query.first_name, last_name: search_query.last_name}
    uri = URI("#{config['url']}?#{q.to_query}")
    result = nil

    begin
      raise 'generic lookup service is not configured' if config['url'].blank?

      LookupApi.parse_uri_without_timeout('not_used_method_name', uri) do |response|
        if response.code == '200'
          result = JSON.parse(response.body)
        else
          Rails.logger.error "LookupApi error: #{response.code}, #{response.body}."
          # required to show not found screen
          raise LookupApi::RecordNotFound
        end
      end
    rescue Timeout::Error
      Rails.logger.error "LOOKUP: timeout URL: #{uri}" if AppConfig['api_debug_logging']
      ErrorLogRecord.log("LOOKUP: timeout", uri: uri)
      LogRecord.lookup_timeout(uri)

      raise LookupApi::RecordNotFound
    end

    VriAdapter.new(result).to_registration
  end
end
