class LookupService < LookupApi

  # stub registration lookup
  def self.registration(record)
    if AppConfig['enable_dmvid_lookup']
      xml = send_request(record)
      parse(xml)
    else
      { registered: false,
        dmv_match:  false }
    end
  end

  private

  def self.send_request(r)
    q = {
      DMVIDnumber:                  r[:dmv_id] || '',
      ssn9:                         r[:ssn],
      dobMonth:                     r[:dob_month],
      dobDay:                       r[:dob_day],
      dobYear:                      r[:dob_year],
      eligibleCitizen:              r[:eligible_citizen],
      eligible18nextElection:       r[:eligible_18_next_election],
      eligibleVAresident:           r[:eligible_va_resident],
      eligibleNotRevokedUnrestored: r[:eligible_unrevoked_or_restored],
      hashType:                     "SHA-1"
    }

    parse_uri('voterByDMVIDnumber', q)
  end


  # handles the response
  def self.handle_response(res, method = nil)
    if res.code == '200'
      Rails.logger.info("LOOKUP: code=#{res.code}")
      return res.body
    end

    Rails.logger.error("INTERNAL ERROR: LOOKUP code=#{res.code}\m#{res.body}")

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
