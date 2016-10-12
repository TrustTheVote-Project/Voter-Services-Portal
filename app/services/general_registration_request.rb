class GeneralRegistrationRequest
  class RegistrationError < StandardError
  end

  def self.perform(registration, config)
    params = VriRegistrationAdapter.new(registration).to_request
    uri = URI(config['registration_url'])
    Rails.logger.info(uri.to_s)
    result = nil

    begin
      raise 'generic lookup service is not configured' if config['registration_url'].blank?
      Rails.logger.debug params.to_json
      LookupApi.post_request(uri, params) do |response|
        if response.code == '200'
          result = JSON.parse(response.body)
          Rails.logger.debug(result)
        else
          Rails.logger.error "GeneralRegistrationRequest error: #{response.code}, #{response.body}."
          raise RegistrationError
        end
      end
    rescue Timeout::Error
      Rails.logger.error "REG-REQUEST: timeout URL: #{uri}" if AppConfig['api_debug_logging']
      ErrorLogRecord.log("REG-REQUEST: timeout", uri: uri)
      LogRecord.lookup_timeout(uri)

      raise RegistrationError
    end
    true
  end
end
