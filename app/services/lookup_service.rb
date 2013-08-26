class LookupService < LookupApi

  # stub registration lookup
  def self.registration(record)
    if AppConfig['enable_dmvid_lookup'] && record_complete?(record)
      return dmv_address_lookup(record)
    else
      return { registered: false, dmv_match: false }
    end
  rescue RecordNotFound
    { registered: false, dmv_match: false }
  end

  # Returns absentee status items in an array.
  # Raises: LookupApi::RecordNotFound if record wasn't found
  # for whatever reason.
  def self.absentee_status_history(voter_id, dob, locality)
    election_ids = collect_election_ids_for_voter(voter_id)
    return collect_elections_details(voter_id, election_ids, dob, locality)
  rescue Timeout::Error
    raise LookupTimeout
  end

  private

  def self.collect_election_ids_for_voter(voter_id)
    q = { voterID: voter_id }

    xml = parse_uri('electionsByVoter', q) do |res, method = nil|
      raise RecordNotFound if res.code != '200'
      res.body
    end

    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!
    doc.css('vip_object > election').map do |o|
      (o.css('election').first)['id']
    end
  end

  def self.collect_elections_details(voter_id, election_ids, dob, locality)
    election_ids.map do |election_id|
      collect_election_details(voter_id, election_id, dob, locality)
    end.flatten
  end

  def self.collect_election_details(voter_id, election_id, dob, locality)
    q = {
      voterIDnumber:  voter_id,
      localityName:   locality,
      dobMonth:       dob.month,
      dobDay:         dob.day,
      dobYear:        dob.year,
      electionUID:    election_id }

    xml = parse_uri('voterAdminHistoryByVID', q) do |res, method = nil|
      raise RecordNotFound if res.code != '200'
      res.body
    end

    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!
    doc.css('voterTransactionRecord').map do |vtr|
      date      = vtr.css('date').text

      { request:   vtr.css('form type').text,
        action:    vtr.css('action').text,
        date:      Date.parse(date).strftime('%d %b %Y'),
        registrar: vtr.css('leo').text.to_s.strip,
        notes:     vtr.css('notes').text.to_s.strip }
    end
  end

  def self.dmv_address_lookup(r)
    parse(send_request(r))
  end

  def self.record_complete?(r)
    r[:dmv_id].present? &&
      r[:ssn].present? &&
      r[:dob_month].present? &&
      r[:dob_day].present? &&
      r[:dob_year].present?
  end

  def self.send_request(r)
    q = {
      DmvIDnumber:                  r[:dmv_id] || '',
      ssn9:                         r[:ssn].to_s.gsub(/[^0-9]/, ''),
      dobMonth:                     r[:dob_month],
      dobDay:                       r[:dob_day],
      dobYear:                      r[:dob_year],
      eligibleCitizen:              r[:eligible_citizen],
      eligible18nextElection:       r[:eligible_18_next_election],
      eligibleVAresident:           r[:eligible_va_resident],
      eligibleNotRevokedUnrestored: r[:eligible_unrevoked_or_restored],
      hashType:                     "none"
    }

    parse_uri 'voterByDMVIDnumber', q do |res, method = nil|
      if res.code == '200'
        Rails.logger.info("LOOKUP: code=#{res.code}\n#{res.body}") if AppConfig['api_debug_logging']
        return res.body
      end

      # raise legit not found error
      if res.code == '400' && (
         /Voter wasn't found in the system/i =~ res.body ||
         /not found/i =~ res.body ||
         /not available/i =~ res.body ||
         /not active/i =~ res.body)

        Rails.logger.error("NOT FOUND: LOOKUP code=#{res.code}\n#{res.body}") if AppConfig['api_debug_logging']
        raise RecordNotFound
      end

      Rails.logger.error("INTERNAL ERROR: LOOKUP code=#{res.code}\n#{res.body}") if AppConfig['api_debug_logging']
      ErrorLogRecord.log("Lookup: unknown error", code: res.code, body: res.body)
      LogRecord.lookup_error(res.body)

      raise RecordNotFound
    end
  end

  def self.parse(xml)
    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!

    prot = doc.css('CheckBox[Type="IsProtected"]').try(:text) == 'yes'

    o = {
      registered: doc.css('CheckBox[Type="SBEMatch"]').try(:text) == 'yes',
      dmv_match:  doc.css('CheckBox[Type="DMVMatch"]').try(:text) == 'yes'
    }

    # if protected, don't include the address
    return o if prot

    ea = doc.css('ElectoralAddress').first
    if ea
      if ft = ea.css('FreeTextAddress').first
        zip = ft.css("AddressLine[type='Zip']").try(:text).to_s

        o[:address] = {
          address_1:      ft.css("AddressLine[type='AddressLine1']").try(:text),
          address_2:      ft.css("AddressLine[type='AddressLine2']").try(:text),
          town:           ft.css("AddressLine[type='City']").try(:text),
          zip5:           zip[0, 5],
          zip4:           zip[5, 4]
        }
      elsif pa = ea.css('PostalAddress').first
        o[:address] = {
          address_1:      pa.css('Thoroughfare').first.try(:text),
          address_2:      pa.css('OtherDetail').try(:text),
          town:           pa.css('Locality').try(:text),
          zip5:           (pa.css('PostCode').try(:text) || "")[0, 5]
        }
      end
    end

    o
  end
end
