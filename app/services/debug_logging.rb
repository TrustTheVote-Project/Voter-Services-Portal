class DebugLogging

  def self.log(method, res)
    log_response(method, res)
    log_response_to_file(method, res.body)
  end

  def self.log_response(method, res)
    return unless AppConfig['api_debug_logging']
    Rails.logger.info("LOOKUP: #{method} code=#{res.code}\n#{res.body}")
  end

  def self.log_response_to_file(method, data)
    return unless AppConfig['enable_eml_log']

    File.open("#{Rails.root}/log/last_#{method}.xml", "wb") { |f| f.write(data) }
  rescue => e
    Rails.logger.error("INTERNAL ERROR: Failed to write log/last_#{method}.xml: #{e}") if AppConfig['api_debug_logging']
  end

end
