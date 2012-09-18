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
        xml = search_by_voter_id(search_query.voter_id, search_query.locality)
      end
    else
      xml = search_by_data(search_query)
    end

    rec = parse(xml)
    rec.existing = true;
    rec

  rescue RecordNotFound
    nil
  end

  def self.sample_record(vid)
    if vid =~ /12312312\d/
      r = FactoryGirl.build(:existing_residential_voter)
      if vid == "123123124"
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

  def self.search_by_voter_id(vid, locality)
    vid = vid.to_s.gsub(/[^\d]/, '')
    locality = URI.escape(locality)
    uri = URI("https://wscp.sbe.virginia.gov/electionlist.svc/v1/#{AppConfig['api_key']}/#{locality}/#{vid}")
    parse_uri(uri)
  end

  def self.search_by_data(query)
    uri = URI("https://wscp.sbe.virginia.gov/electionlist.svc/v1/#{AppConfig['api_key']}/search/?lastName=#{lastName}")
    parse_uri(uri)
  end

  def self.parse_uri(uri)
    req = Net::HTTP::Get.new(uri.request_uri)
    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true, verify_mode: OpenSSL::SSL::VERIFY_NONE) do |http|
      http.request(req)
    end

    res.code == '200' && res.body || raise(RecordNotFound)
  end

  def self.parse(xml)
    raise RecordNotFound if /Voter Record not found/ =~ xml

    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!

    # John: Consider address_confidential == "yes" an internal error and
    # return record-not-found.
    if doc.css('CheckBox[Type="AddressConfidential"]').try(:text) == "yes"
      raise RecordNotFound
    end

    vvr = doc.css('ElectoralAddress PostalAddress').first
    vvr_thoroughfare = vvr.css('Thoroughfare').first
    vvr_apt = vvr.css('OtherDetail[type="ApartmentNumber"]').try(:text)
    vvr_zip = vvr.css('PostCode').try(:text) || ""
    vvr_zip5, vvr_zip4 = vvr_zip.scan(/(\d{5})(\d{4})?/).flatten

    felony                = doc.css('CheckBox[Type="Felony"]').try(:text) == 'yes'
    incapacitated         = doc.css('CheckBox[Type="Incapacitated"]').try(:text) == 'yes'
    rights_revoked        = "0"
    rights_revoked_reason = nil
    rights_restored       = nil
    rights_restored_on    = nil

    # John: Ignoring incapacitated / felony until we get samples of restored rights
    #
    # if felony || incapacitated
    #   rights_revoked_reason = felony ? 'felony' : 'mental'
    #   rights_revoked  = "1"
    #   rights_restored = "0"
    # end

    military = doc.css("CheckBox[Type='Military']").try(:text) == 'yes'
    overseas = doc.css("CheckBox[Type='Overseas']").try(:text) == 'yes'
    current_absentee_until = doc.css('Message AbsenteeExpiritionDate').try(:text)
    if current_absentee_until.blank?
      if military || overseas
        current_absentee_until = Date.today.advance(years: 1).end_of_year
      else
        current_absentee_until = nil
      end
    else
      current_absentee_until = Date.parse(current_absentee_until)
    end

    absentee_for_elections = []
    if doc.css("CheckBox[Type='ElectionLevelAbsentee']").try(:text) == 'yes'
      absentee_for_elections = doc.css("Election").map do |e|
        e.css("Absentee").any? && e.css("FutureElection").text == 'yes' ? e.css("ElectionName").text : nil
      end.compact
    end

    upcoming_elections = []
    nowy = Date.today.year
    doc.css("Election").each do |e|
      name = e.css("ElectionName").text.strip
      year = name[0, 4].to_i
      upcoming_elections.unshift(name) if year >= nowy
    end

    options = {
      voter_id:               doc.css('VoterIdentification').first.try(:[], 'Id'),
      first_name:             doc.css('GivenName').try(:text),
      middle_name:            doc.css('MiddleName').try(:text),
      last_name:              doc.css('FamilyName').try(:text),
      phone:                  doc.css('Contact Telephone Number').try(:text),
      gender:                 doc.css('Gender').try(:text).to_s.capitalize,
      lang_preference:        doc.css('PreferredLanguage').try(:text),

      rights_revoked:         rights_revoked,
      rights_revoked_reason:  rights_revoked_reason,
      rights_restored:        rights_restored,
      rights_restored_on:     rights_restored_on,

      vvr_is_rural:           "0",
      vvr_street_number:      vvr_thoroughfare['number'],
      vvr_street_name:        vvr_thoroughfare['name'],
      vvr_street_type:        vvr_thoroughfare['type'],
      vvr_apt:                vvr_apt,
      vvr_town:               vvr.css('Locality').try(:text),
      vvr_zip5:               vvr_zip5,
      vvr_zip4:               vvr_zip4,
      has_existing_reg:       "0",
      ma_is_same:             "0",

      # Every record that comes from the DB has this set to 'no',
      # otherwise it's an error
      is_confidential_address: '0',

      poll_precinct:          doc.css('PollingDistrict Association[Id="PrecinctName"]').try(:text),
      poll_locality:          doc.css('PollingDistrict Association[Id="LocalityName"]').try(:text),
      poll_district:          doc.css('PollingDistrict Association[Id="ElectoralDistrict"]').try(:text),

      ssn4:                   "XXXX",
      current_residence:      military || overseas ? "outside" : "in",
      current_absentee_until: current_absentee_until,
      absentee_for_elections: absentee_for_elections,
      upcoming_elections:     upcoming_elections
    }

    ma_address    = doc.css('MailingAddress AddressLine[type="MailingAddressLine1"]').try(:text)
    ma_address_2  = doc.css('MailingAddress AddressLine[type="MailingAddressLine2"]').try(:text)
    ma_city       = doc.css('MailingAddress AddressLine[type="MailingCity"]').try(:text)
    ma_state      = doc.css('MailingAddress AddressLine[type="MailingState"]').try(:text)
    ma_zip        = doc.css('MailingAddress AddressLine[type="MailingZip"]').try(:text) || ""
    ma_zip5, ma_zip4 = ma_zip.scan(/(\d{5})(\d{4})?/).flatten

    districts = []
    [ [ 'Electoral', 'ElectoralDistrict' ],
      [ 'Congressional', 'CongressionalDistrict' ],
      [ 'Senate', 'SenateDistrict' ],
      [ 'State House', 'StateHouseDistrict' ] ].each do |key, id|
      v = doc.css('PollingDistrict Association[Id="' + id + '"]').try(:text)
      districts.push([ key, v ]) unless v.blank?
    end
    options[:districts] = districts

    if !military && !overseas
      options.merge!({
        ma_address:           ma_address,
        ma_address_2:         ma_address_2,
        ma_city:              ma_city,
        ma_state:             ma_state,
        ma_zip5:              ma_zip5,
        ma_zip4:              ma_zip4 || "" })
    else
      if %w( APO DPO FPO ).include?(ma_city.upcase)
        options.merge!({
          mau_type:           'apo',
          apo_address:        ma_address,
          apo_address_2:      ma_address_2,
          apo_1:              ma_city.upcase,
          apo_2:              ma_state.upcase,
          apo_zip5:           ma_zip5 })
      else
        options.merge!({
          mau_type:           'non-us',
          mau_address:        ma_address,
          mau_address_2:      ma_address_2,
          mau_city:           ma_city,
          mau_city_2:         nil,
          mau_state:          ma_state,
          mau_postal_code:    ma_zip,
          mau_country:        doc.css('MailingAddress AddressLine[type="MailingCountry"]').try(:text) })
      end

      # We don't have info about this, so always available for now
      options[:vvr_uocava_residence_available] = '1'
    end
    Registration.new(options.merge(existing: true))
  end

end
