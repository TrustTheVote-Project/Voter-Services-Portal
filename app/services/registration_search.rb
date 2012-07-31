require 'net/http'

# Searches for existing registrations with given attributes
class RegistrationSearch

  # Raised when no record was found
  class RecordNotFound < StandardError; end

  def self.perform(search_query)
    xml = unless search_query.voter_id.blank?
      search_by_voter_id(search_query.voter_id)
    else
      search_by_data(search_query)
    end

    rec = parse(xml)
    rec.existing = true;
    rec
  end

  def self.search_by_voter_id(vid)
    vid = vid.to_s.gsub(/[^\d]/, '')
    uri = URI("https://wscp.sbe.virginia.gov/ElectionList.svc/#{vid}")
    req = Net::HTTP::Get.new(uri.request_uri)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(req)
    end

    res.body
  end

  def self.search_by_data(query)
    k, v = SEED_DATA.to_a.find do |vid, data|
      data[:last_name].to_s.downcase == query.last_name.to_s.downcase &&
      data[:ssn4].to_s == query.ssn4.to_s &&
      data[:dob] == query.dob
    end

    v
  end

  def self.parse(xml)
    raise RecordNotFound if /Voter Record not found/ =~ xml

    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!

    options = {
      first_name:   doc.css('GivenName').try(:text),
      middle_name:  doc.css('MiddleName').try(:text),
      last_name:    doc.css('FamilyName').try(:text)
    }

    Registration.new(options.merge(existing: true))
  end

end
