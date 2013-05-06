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
    # easter eggs
    raise SubmissionError if reg.last_name == 'faileml310'
    return { success: reg.dmv_id.size == 9, voter_id: '123456789' } if reg.dmv_id

    # don't submit anything if disabled
    return {} unless submission_enabled?

    res = send_request(reg)

    raise SubmissionError unless successful_response?(res)

    return extract_voter_id(res)
  rescue => e
    ErrorLogRecord.log("Submit EML310", error: "Failed to submit", response: res)
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

  # parses the response and returns the voter ID
  def self.extract_voter_id(res)
    # TBD and implemented
    # when registering new records. success=true means we added new record
    # success=false means there was the record with this data already
    voter_id = "123456789"
    success  = true

    raise SubmissionError.new("Voter ID is missing") if voter_id.blank?

    return { success: success, voter_id: voter_id }
  end
end
