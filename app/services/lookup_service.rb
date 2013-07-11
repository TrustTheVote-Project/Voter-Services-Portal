class LookupService < LookupApi

  # stub registration lookup
  def self.registration(record)
    if AppConfig['enable_dmvid_lookup'] && record_complete?(record)
      xml = send_request(record)
      parse(xml)
    else
      { registered: false,
        dmv_match:  false }
    end
  rescue RecordNotFound
    { registered: false, dmv_match: false }
  end

  private

  def self.record_complete?(r)
    r[:dmv_id].present?
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

    parse_uri('voterByDMVIDnumber', q)
  end


  # handles the response
  def self.handle_response(res, method = nil)
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

  def self.parse(xml)
    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!

    o = {
      registered: doc.css('CheckBox[type="Registered"]').try(:text) == 'yes',
      dmv_match:  doc.css('CheckBox[type="DMVMatch"]').try(:text) == 'yes'
    }

    ea = doc.css('ElectoralAddress').first
    if ea
      if ft = ea.css('FreeTextAddress').first
        o[:address] = {
          address_1:      ft.css("AddressLine[type='AddressLine1']").try(:text),
          address_2:      ft.css("AddressLine[type='AddressLine2']").try(:text),
          county_or_city: ft.css("AddressLine[type='Jurisdiction']").try(:text),
          town:           ft.css("AddressLine[type='City']").try(:text),
          zip5:           ft.css("AddressLine[type='Zip']").try(:text).to_s[0, 5]
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
