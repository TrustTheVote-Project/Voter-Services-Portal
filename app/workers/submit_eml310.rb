require 'builder'

class SubmitEml310

  include Sidekiq::Worker

  # submits registration form to the remote service
  def perform(reg_id)
    reg = Registration.find(reg_id)

    uri = URI(SubmitEml310.submission_url)
    req = Net::HTTP::Post.new(uri.path)
    req.body = registration_xml(reg)
    req.content_type = 'multipart/form-data'

    res = Net::HTTP.start(uri.hostname, uri.port) do |http|
      http.request(req)
    end

    unless successful_response?(res)
      ErrorLogRecord.log("Submit EML310", error: "Failed to submit", response: res)
    end
  rescue ActiveRecord::RecordNotFound
    ErrorLogRecord.log("Submit EML310", error: "Record not found", id: reg_id)
  end

  # schedules the submission in background if the submission
  # is enabled.
  def self.schedule(reg)
    SubmitEml310.perform_async(reg.id) if submission_enabled?
  end

  private

  def successful_response?(res)
    res.kind_of? Net::HTTPSuccess
  end

  def self.submission_enabled?
    submission_url.present?
  end

  def self.submission_url
    @submission_url ||= AppConfig['eml310_submit_url']
  end

  # returns registration EML310
  def registration_xml(reg)
    xml = Builder::XmlMarkup.new
    Eml310Builder.build(reg, xml)
  end

end
