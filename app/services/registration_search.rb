# Searches for existing registrations with given attributes
class RegistrationSearch < AbstractRegistrationSearch

  def self.perform(search_query)
    xml = nil
    if SearchController.helpers.lookup_service_config['id_and_locality_style']
      vid = search_query.voter_id 

      unless vid.blank?
        if vid.to_s =~ /^a/
          return sample_record(vid)
        else
          xml = search_by_voter_id(vid, search_query.locality, search_query.dob)
        end
      else
        xml = search_by_data(search_query.ssn4, search_query.locality, search_query.dob, search_query.first_name, search_query.last_name)
      end
    else
      return GeneralRegistrationSearch.perform(search_query, SearchController.helpers.lookup_service_config)
    end
    
    DebugLogging.log_response_to_file("eml330", xml)

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
      ppl_zip = ppl.css('AddressLine[type="Zip"]').try(:text)
      options[:ppl_location_name] = ppl.css('AddressLine[type="LocationName"]').try(:text)
      options[:ppl_address]       = ppl.css('AddressLine[type="Address"]').try(:text)
      options[:ppl_city]          = ppl.css('AddressLine[type="City"]').try(:text)
      options[:ppl_state]         = ppl.css('AddressLine[type="State"]').try(:text)
      options[:ppl_zip]           = ppl_zip

      if ppl_zip.present?
        options[:ppl_zip] = zip9_to_dashed(ppl_zip)
      end

      vl = ppl.css('AddressLine').map do |al|
        val = al.text
        val = options[:ppl_zip] if al['type'] == 'Zip'

        { seq: al[:seqn].to_i, val: val }
      end.sort_by { |vls| vls[:seq] }

      options[:voting_location] = vl.map { |v| v[:val] }.join(', ')
    end

    ppl = doc.css('PollingPlace[Channel="postal"] FreeTextAddress').first
    if ppl
      vl = ppl.css('AddressLine').map do |al|
        val = al.text
        val = zip9_to_dashed(val) if al['type'] == 'Zip'

        { seq: al[:seqn].to_i, val: val }
      end.sort_by { |vls| vls[:seq] }

      options[:electoral_board_contacts] = vl.map { |v| v[:val] }.join(', ')
    end

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

    if military || overseas
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

  def self.zip9_to_dashed(zip)
    return zip if zip.blank?

    zip5, zip4 = zip.scan(/(\d{5})-?(\d{4})?/).flatten
    return [ zip5, zip4 ].reject(&:blank?).join('-')
  end

end
