# Searches for existing registrations with given attributes
class AbstractRegistrationSearch < LookupApi

  def self.search_by_voter_id(vid, locality, dob)
    q = {
      voterIDnumber:  vid.to_s.gsub(/[^\d]/, '').rjust(9, '0'),
      localityName:   locality,
      dobMonth:       dob.month,
      dobDay:         dob.day,
      dobYear:        dob.year }

    query('voterByVID', q)
  end

  def self.search_by_data(ssn4, locality, dob, first_name, last_name)
    q = {
      ssn4:           ssn4,
      localityName:   locality,
      dobMonth:       dob.month,
      dobDay:         dob.day,
      dobYear:        dob.year,
      firstName:      first_name,
      lastName:       last_name }

    query('voterBySSN4', q)
  end

  def self.query(method, q)
    parse_uri(method, q) do |res, method = nil|
      handle_response(res, method)
    end
  end

  def self.handle_response(res, method = nil)
    Rails.logger.info("LOOKUP: #{method} code=#{res.code}\n#{res.body}") if AppConfig['api_debug_logging']

    return res.body if res.code == '200'

    # raise known errors
    if res.code == '400'
      raise RecordIsConfidential if /(cannot be displayed|not available)/i =~ res.body
      raise RecordIsInactive if /is not active/ =~ res.body
    end

    # log unknown errors
    if res.code != '404'
      ErrorLogRecord.log("Lookup: unknown error", code: res.code, body: res.body)
      LogRecord.lookup_error(res.body)
    end

    raise RecordNotFound
  end

  protected

  # slightly better escaping
  def self.escape(s)
    s ? URI.escape(s).gsub('&', '%26') : s
  end

  def self.zip9_to_dashed(zip)
    return zip if zip.blank?

    zip5, zip4 = zip.scan(/(\d{5})-?(\d{4})?/).flatten
    return [ zip5, zip4 ].reject(&:blank?).join('-')
  end

end
