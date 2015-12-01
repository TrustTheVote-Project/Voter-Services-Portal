require 'builder'
require 'net/http'

class SubmitEml310

  # Possible reasons: bad EML310, service unavailable
  class SubmissionError < StandardError
    attr_reader :code

    def initialize(code = nil, message = nil)
      super message
      @code = code
    end
  end

  def self.submit_update(reg)
    return submit(reg, "voterRecordUpdateRequest")
  rescue SubmissionError => e
    if e.message == 'not registered'
      return submit_new(reg)
    else
      raise e
    end
  end

  def self.submit_new(reg)
    return submit(reg, "voterRegistrationRequest")
  rescue SubmissionError => e
    if e.message == 'already registered'
      return submit_update(reg)
    else
      raise e
    end
  end

  private

  def self.submit(reg, method)
    response = nil
    result = false # no online submission (or signature pending)

    # don't submit anything if disabled
    if submission_enabled?
      response = send_request(reg, method)
      result = parse(response)
    end
    
    if !AppConfig['enable_eml_post']
      return true
    end

    result
  rescue => e
    if e.kind_of? SubmissionError
      raise e
    else
      Rails.logger.error("INTERNAL ERROR: SUBMIT_EML310 - Unknown error: #{e}") if AppConfig['api_debug_logging']
      raise SubmissionError
    end
  end

  def self.send_request(reg, method, body = nil)
    uri = URI("#{SubmitEml310.submission_url}/#{method}")
    req = Net::HTTP::Post.new(uri.path)
    req.body = body || registration_xml(reg)
    req.content_type = 'multipart/form-data'

    Rails.logger.info("SUBMIT_EML310: #{uri}") if AppConfig['api_debug_logging']

    netlog = nil
    if AppConfig['enable_eml_log']
      begin
        Rails.logger.debug("LAST_EML310: " + req.body)
        File.open("#{Rails.root}/log/last_eml310.xml", "wb") { |f| f.write(req.body) }
        netlog = File.open("#{Rails.root}/log/last_eml310.netlog", "wb")
        netlog << "#{uri}\n"
      rescue => e
        Rails.logger.error("INTERNAL ERROR: SUBMIT_EML310 - Failed to write log/last_eml310.xml: #{e}") if AppConfig['api_debug_logging']
      end
    end

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.use_ssl      = uri.scheme == 'https'
    http.open_timeout = 60
    http.read_timeout = 60
    http.verify_mode  = OpenSSL::SSL::VERIFY_NONE
    http.set_debug_output(netlog)
    return http.start do |http|
      http.request(req)
    end
  ensure
    netlog.close if netlog
  end

  def self.submission_enabled?
    submission_url.present? && AppConfig['enable_eml_post']
  end

  def self.submission_url
    @submission_url ||= begin
      c = AppConfig['private']['wscp']
      url_parts = [ c['url_base'] ]
      url_parts << c['submit_path'] unless c['lookup_path'].blank?
      url_parts << c['api_key'] unless c['api_key'].blank?
      url_parts.join('/')
    end
  end

  # returns registration EML310
  def self.registration_xml(reg)
    xml = Builder::XmlMarkup.new
    Eml310Builder.build(reg, xml)
  end

  def self.successful_response?(res)
    res.code == '200'
  end

  # parses the response
  def self.parse(res)
    Rails.logger.info "SUBMIT_EML310: Response code=#{res.code}\n#{res.body}" if AppConfig['api_debug_logging']

    if successful_response?(res)
      return res.body !~ /pending signature/i
    else
      raise SubmissionError.new(res.code, res.body)
    end
  end
end
