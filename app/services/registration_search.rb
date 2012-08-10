require 'net/http'

# Searches for existing registrations with given attributes
class RegistrationSearch

  # Raised when no record was found
  class RecordNotFound < StandardError; end

  def self.perform(search_query)
    unless search_query.voter_id.blank?
      if search_query.first_name == 'vasample'
        return sample_record(search_query.voter_id)
      else
        xml = search_by_voter_id(search_query.voter_id)
      end
    else
      xml = search_by_data(search_query)
    end

    rec = parse(xml)
    rec.existing = true;
    rec
  end

  def self.sample_record(vid)
    if vid =~ /12312312\d/
      r = FactoryGirl.build(:existing_residential_voter)
      if vid == "123123124"
        r.current_absentee = "1"
        r.absentee_for_elections = [ "Election 1", "Election 2" ]
      end
      r
    else
      r = FactoryGirl.build(:existing_overseas_voter)
      if vid == "111222334"
        r.current_absentee_until = 1.year.from_now.end_of_year
      end
      r
    end
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

    ma_zip = doc.css('MailingAddress PostCode[type="ZipCode"]').try(:text) || ""
    ma_zip5, ma_zip4 = ma_zip.scan(/(\d{5})(\d{4})?/).flatten

    rights                = doc.css('Felony, Incapacitated')
    rights_revoked        = "0"
    rights_revoked_reason = nil
    rights_restored       = nil
    rights_restored_on    = nil

    if rights.any?
      rights_revoked = "1"

      pending = rights.select { |e| e["RightsRestored"] == "no" }.last
      if pending
        rights_revoked_reason = pending.name == "Felony" ? "felony" : "mental"
        rights_restored = "0"
      else
        rights_revoked_reason = rights.last.name == "Felony" ? "felony" : "mental"
        rights_restored = "1"
        rights_restored_on = Kronic.parse(rights.last.css("RestoreDate").text)
      end
    end

    options = {
      first_name:             doc.css('GivenName').try(:text),
      middle_name:            doc.css('MiddleName').try(:text),
      last_name:              doc.css('FamilyName').try(:text),
      phone:                  doc.css('Contact Telephone Number').try(:text),
      gender:                 doc.css('Gender').try(:text).to_s.capitalize,

      rights_revoked:         rights_revoked,
      rights_revoked_reason:  rights_revoked_reason,
      rights_restored:        rights_restored,
      rights_restored_on:     rights_restored_on,

      ma_is_same:             "0",
      ma_address:             doc.css('MailingAddress Thoroughfare').try(:text),
      ma_city:                doc.css('MailingAddress Locality').try(:text),
      ma_state:               doc.css('MailingAddress AdministrativeArea[type="StateCode"]').try(:text),
      ma_zip5:                ma_zip5,
      ma_zip4:                ma_zip4 || "",

      is_confidential_address: doc.css('Confidentiality').try(:text) == "yes" ? "1" : "0",

      poll_precinct:          doc.css('PollingDistrict Association[Id="PrecinctName"]').try(:text),
      poll_locality:          doc.css('PollingDistrict Association[Id="LocalityName"]').try(:text),
      poll_district:          doc.css('PollingDistrict Association[Id="ElectoralDistrict"]').try(:text),

      ssn4:                   "XXXX",
      current_residence:      "in",
      current_absentee:       doc.css('CheckBox[Type="AbsenteeStatus"]').try(:text) == 'yes' ? "1" : "0",
      absentee_for_elections: []
    }

    Registration.new(options.merge(existing: true))
  end

end
