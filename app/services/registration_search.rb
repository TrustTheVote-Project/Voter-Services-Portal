# Searches for existing registrations with given attributes
class RegistrationSearch < LookupApi

  def self.perform(search_query)
    vid = search_query.voter_id

    unless vid.blank?
      if vid.to_s =~ /^a/
        return sample_record(vid)
      else
        xml = search_by_voter_id(vid, search_query.locality, search_query.dob)
      end
    else
      xml = search_by_data(search_query)
    end

    if AppConfig['enable_eml_log']
      begin
        File.open("#{Rails.root}/log/last_eml330.xml", "wb") { |f| f.write(xml) }
      rescue => e
        Rails.logger.error("INTERNAL ERROR: LOOKUP - Failed to write log/last_eml330.xml: #{e}") if AppConfig['api_debug_logging']
      end
    end

    rec = parse(xml)

    if rec.gender.blank?
      ErrorLogRecord.log("Parsing error", error: "no gender", voter_id: rec.voter_id)
    end

    rec.existing = true
    rec.dob ||= search_query.dob
    rec
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

  def self.search_by_voter_id(vid, locality, dob)
    q = {
      voterIDnumber:  vid.to_s.gsub(/[^\d]/, '').rjust(9, '0'),
      localityName:   locality,
      dobMonth:       dob.month,
      dobDay:         dob.day,
      dobYear:        dob.year }

    query('voterByVID', q)
  end

  def self.search_by_data(query)
    q = {
      ssn4:           query.ssn4,
      localityName:   query.locality,
      dobMonth:       query.dob.month,
      dobDay:         query.dob.day,
      dobYear:        query.dob.year,
      firstName:      query.first_name,
      lastName:       query.last_name }

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
      raise RecordIsConfidential if /cannot be displayed/ =~ res.body
      raise RecordIsInactive if /is not active/ =~ res.body
    end

    # log unknown errors
    if res.code != '404'
      ErrorLogRecord.log("Lookup: unknown error", code: res.code, body: res.body)
      LogRecord.lookup_error(res.body)
    end

    raise RecordNotFound
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

    voter_id = doc.css('VoterIdentification').first.try(:[], 'Id')

    vvr = doc.css('ElectoralAddress PostalAddress').first
    if vvr
      vvr_address_1 = vvr.css('Thoroughfare').first.try(:text)
      vvr_address_2 = vvr.css('OtherDetail').try(:text)
      vvr_town      = vvr.css('Locality').try(:text)
      vvr_zip       = vvr.css('PostCode').try(:text) || ""
    else
      vvr = doc.css('ElectoralAddress FreeTextAddress').first
      vvr_address_1 = vvr.css('AddressLine[type="AddressLine1"]').try(:text)
      vvr_address_2 = vvr.css('AddressLine[type="AddressLine2"]').try(:text)
      vvr_town      = vvr.css('AddressLine[type="City"]').try(:text)
      vvr_state     = vvr.css('AddressLine[type="State"]').try(:text)
      vvr_zip       = vvr.css('AddressLine[type="Zip"]').try(:text) || ""
    end
    vvr_zip5, vvr_zip4 = vvr_zip.scan(/(\d{5})(\d{4})?/).flatten
    vvr_is_rural = "0"

    felony                    = doc.css('CheckBox[Type="Felony"]').try(:text) == 'yes'
    incapacitated             = doc.css('CheckBox[Type="Incapacitated"]').try(:text) == 'yes'
    rights_revoked            = "0"
    rights_felony             = nil
    rights_mental             = nil
    rights_felony_restored    = nil
    rights_felony_restored_on = nil
    rights_felony_restored_in = nil
    rights_mental_restored    = nil
    rights_mental_restored_on = nil

    ela      = doc.css("CheckBox[Type='ElectionLevelAbsentee']").try(:text) == 'yes'
    oa       = doc.css("CheckBox[Type='OngoingAbsentee']").try(:text) == 'yes'
    military = doc.css("CheckBox[Type='Military']").try(:text) == 'yes'
    overseas = doc.css("CheckBox[Type='Overseas']").try(:text) == 'yes'

    if !oa
      current_absentee_until = nil
    else
      current_absentee_until = doc.css('Message AbsenteeExpiritionDate').try(:text)
      if current_absentee_until.blank?
        if military || overseas
          ErrorLogRecord.log("Parsing error", error: "AbsenteeExpiritionDate is missing", voter_id: voter_id)
          current_absentee_until = Date.today.advance(years: 1).end_of_year
        else
          current_absentee_until = nil
        end
      else
        current_absentee_until = Date.parse(current_absentee_until)
      end
    end

    past_elections = []
    upcoming_elections = []
    absentee_for_elections_uids = []
    absentee_for_elections = []

    doc.css("Election").map do |e|
      absentee = e.css("Absentee").any?
      name = e.css("ElectionName").text.strip
      approved = absentee && e.css("AbsenteeStatus").text.strip == 'Approved'

      if e.css("CheckBox[Type='FutureElection']").text == 'no'
        type = absentee ? "Voted absentee" : e.css("CheckBox[Type='Voted']").text == "yes" ? "Voted in person" : "Did not vote"
        past_elections.push([ name, type ])
      else
        upcoming_elections.unshift(name)

        if ela && approved
          absentee_for_elections.push(name)
          absentee_for_elections_uids.push((e.css("ElectionIdentifier").first)["IdNumber"]);
        end
      end
    end

    ceid  = AppConfig['current_election']['uid']
    obe_1 = oa || (ela && absentee_for_elections_uids.include?(ceid))
    obe_2 = military || overseas

    poll_locality = doc.css('PollingDistrict Association[Id="LocalityName"]').try(:text)

    options = {
      voter_id:                   voter_id,
      first_name:                 fn = doc.css('GivenName').try(:text),
      middle_name:                mn = doc.css('MiddleName').try(:text),
      last_name:                  ln = doc.css('FamilyName').try(:text),
      phone:                      doc.css('Contact Telephone Number').try(:text),
      gender:                     doc.css('Gender').try(:text).to_s.capitalize,
      lang_preference:            doc.css('PreferredLanguage').try(:text),

      rights_revoked:             rights_revoked,
      rights_felony:              rights_felony,
      rights_felony_restored:     rights_felony_restored,
      rights_felony_restored_on:  rights_felony_restored_on,
      rights_felony_restored_in:  rights_felony_restored_in,
      rights_mental_restored:     rights_mental_restored,
      rights_mental_restored_on:  rights_mental_restored_on,

      vvr_is_rural:           vvr_is_rural,
      vvr_address_1:          vvr_address_1,
      vvr_address_2:          vvr_address_2,
      vvr_county_or_city:     poll_locality,
      vvr_town:               vvr_town,
      vvr_state:              "VA",
      vvr_zip5:               vvr_zip5,
      vvr_zip4:               vvr_zip4,
      pr_status:              "1",
      pr_cancel:              "0",
      pr_first_name:          fn,
      pr_middle_name:         mn,
      pr_last_name:           ln,
      pr_is_rural:            vvr_is_rural,
      pr_address:             vvr_address_1,
      pr_address_2:           vvr_address_2,
      pr_city:                vvr_town,
      pr_state:               "VA",
      pr_zip5:                vvr_zip5,
      pr_zip4:                vvr_zip4,
      ma_is_different:        "0",

      # Every record that comes from the DB has this set to 'no',
      # otherwise it's an error
      is_confidential_address: '0',

      poll_precinct:          doc.css('PollingDistrict Association[Id="PrecinctName"]').try(:text),
      poll_locality:          poll_locality,
      poll_district:          doc.css('PollingDistrict Association[Id="ElectoralDistrict"]').try(:text),
      poll_pricinct_split:    doc.css('PollingDistrict Association[Id="PrecinctSplitUID"]').try(:text),

      military:               military,
      overseas:               overseas,
      current_residence:      military || overseas ? "outside" : "in",
      current_absentee_until: current_absentee_until,
      absentee_for_elections: absentee_for_elections,
      past_elections:         past_elections,
      upcoming_elections:     upcoming_elections,
      ob_eligible:            obe_1 && obe_2,

      need_assistance:        "0",
      as_first_name:          "",
      as_middle_name:         "",
      as_last_name:           "",
      as_suffix:              "",
      as_address:             "",
      as_address_2:           "",
      as_city:                "",
      as_state:               "",
      as_zip5:                "",
      as_zip4:                "",

      be_official:            "0"
    }

    ppl = doc.css('PollingPlace[Channel="polling"] FreeTextAddress').first
    if ppl
      options[:ppl_location_name] = ppl.css('AddressLine[type="LocationName"]').try(:text)
      options[:ppl_address]       = ppl.css('AddressLine[type="Address"]').try(:text)
      options[:ppl_city]          = ppl.css('AddressLine[type="City"]').try(:text)
      options[:ppl_state]         = ppl.css('AddressLine[type="State"]').try(:text)
      options[:ppl_zip]           = ppl.css('AddressLine[type="Zip"]').try(:text)
    end

    # For now we decided not to parse MA and stay blank

    # madft = doc.css('MailingAddress FreeTextAddress').first
    # if madft
    #   ma_address      = madft.css('AddressLine[type="AddressLine1"]').try(:text)
    #   ma_address      = madft.css('AddressLine[type="MailingAddressLine1"]').try(:text) if ma_address.blank?
    #   ma_address_2    = madft.css('AddressLine[type="AddressLine2"]').try(:text)
    #   ma_address_2    = madft.css('AddressLine[type="MailingAddressLine2"]').try(:text) if ma_address_2.blank?
    #   ma_city         = madft.css('AddressLine[type="City"]').try(:text)
    #   ma_city         = madft.css('AddressLine[type="MailingCity"]').try(:text) if ma_city.blank?
    #   ma_state        = madft.css('AddressLine[type="State"]').try(:text)
    #   ma_state        = madft.css('AddressLine[type="MailingState"]').try(:text) if ma_state.blank?
    #   ma_zip          = madft.css('AddressLine[type="Zip"]').try(:text)
    #   ma_zip          = madft.css('AddressLine[type="MailingZip"]').try(:text) || "" if ma_zip.blank?
    # else
    #   madpa = doc.css('MailingAddress PostalAddress').first
    #   ma_address      = madpa.css('Thoroughfare').first.try(:text)
    #   ma_address_2    = madpa.css('OtherDetail').try(:text)
    #   ma_city         = madpa.css('Locality').try(:text),
    #   ma_state        = madpa.css('AdministrativeArea').try(:text)
    #   ma_zip          = madpa.css('PostCode').try(:text) || ""
    # end
    # ma_zip5, ma_zip4 = ma_zip.scan(/(\d{5})(\d{4})?/).flatten

    districts = []
    [ [ 'Congressional', 'CongressionalDistrict' ],
      [ 'Senate', 'SenateDistrict' ],
      [ 'State House', 'StateHouseDistrict' ],
      [ 'Local', 'ElectoralDistrict' ] ].each do |key, id|

      v = doc.css('PollingDistrict Association[Id="' + id + '"]').try(:text)
      c = doc.css('PollingDistrict Association[Id="' + id + 'Code"]').try(:text)

      districts.push([ key, [ c, v ] ]) unless v.blank?
    end
    options[:districts] = districts

    if !military && !overseas
      # options.merge!({
      #   ma_address:           ma_address,
      #   ma_address_2:         ma_address_2,
      #   ma_city:              ma_city,
      #   ma_state:             ma_state,
      #   ma_zip5:              ma_zip5,
      #   ma_zip4:              ma_zip4 || "" })
    else
      # if %w( APO DPO FPO ).include?(ma_city.upcase) || (ma_address_2.to_s =~ /\b(apo|dpo|fpo)\b/i)
      #   options.merge!({
      #     mau_type:           'apo',
      #     apo_address:        ma_address,
      #     apo_address_2:      ma_address_2,
      #     apo_city:           ma_city.upcase,
      #     apo_state:          ma_state.upcase,
      #     apo_zip5:           ma_zip5 })
      # else
      #   options.merge!({
      #     mau_type:           'non-us',
      #     mau_address:        ma_address,
      #     mau_address_2:      ma_address_2,
      #     mau_city:           ma_city,
      #     mau_city_2:         nil,
      #     mau_state:          ma_state,
      #     mau_postal_code:    ma_zip,
      #     mau_country:        doc.css('MailingAddress AddressLine[type="MailingCountry"]').try(:text) })
      # end

      # We don't have info about this, so always available for now
      options[:vvr_uocava_residence_available] = '1'
    end
    Registration.new(options.merge(existing: true))
  end

  private

  # slightly better escaping
  def self.escape(s)
    s ? URI.escape(s).gsub('&', '%26') : s
  end

end
