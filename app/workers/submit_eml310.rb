require 'builder'

class SubmitEml310

  # Possible reasons: bad EML310, service unavailable
  class SubmissionError < StandardError; end

  def self.submit_update(reg)
    return submit(reg)
  rescue SubmissionError
    # Ignore the error as per https://www.pivotaltracker.com/story/show/49158483
  end

  def self.submit_new(reg)
    return submit(reg)
  end

  private

  def self.submit(reg)
    response = nil
    result = {}

    # easter egg
    raise SubmissionError if reg.last_name == 'faileml310'

    # don't submit anything if disabled
    if submission_enabled?
      response = send_request(reg)
      raise SubmissionError unless successful_response?(response)
      result = parse(response)
    end

    # easter eggs
    result = (reg.dmv_id.size == 9) if reg.dmv_id

    result
  rescue => e
    ErrorLogRecord.log("Submit EML310", error: "Failed to submit", response: response)
    raise SubmissionError
  end

  def self.send_request(reg)
    uri = URI(SubmitEml310.submission_url)
    req = Net::HTTP::Post.new(uri.path)
    req.body = registration_xml(reg)
    req.content_type = 'multipart/form-data'

    return Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end
  end

  def self.successful_response?(res)
    res.kind_of? Net::HTTPSuccess
  end

  def self.submission_enabled?
    submission_url.present?
  end

  def self.submission_url
    @submission_url ||= AppConfig['eml310_submit_url']
  end

  # returns registration EML310
  def self.registration_xml(reg)
    xml = Builder::XmlMarkup.new
    Eml310Builder.build(reg, xml)
  end

  # parses the response
  def self.parse(res)
    # TBD and implemented
    # when registering new records. 'true' means we added new record
    # 'false' means there was the record with this data already

    true
  end
end
