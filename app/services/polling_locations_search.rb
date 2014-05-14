class PollingLocationsSearch < AbstractRegistrationSearch

  # looks for the polling locations by parameters
  def self.perform(sq)
    if sq.voter_id.blank?
      xml = search_by_data(sq.ssn4, sq.locality, sq.dob, sq.first_name, sq.last_name)
    else
      # search by vid
      xml = search_by_voter_id(sq.voter_id, sq.locality, sq.dob)
    end

    locations = parse(xml)
    raise RecordNotFound if locations.blank?

    return locations
  end

  # parses the response into the list of polling locations
  def self.parse(xml)
    raise RecordNotFound if /Voter Record not found/ =~ xml

    doc = Nokogiri::XML::Document.parse(xml)
    doc.remove_namespaces!

    polling_locations = []

    doc.css('PollingPlace').each do |ppl|
      ppl_zip = ppl.css('AddressLine[type="Zip"]').try(:text)

      postal = ppl['Channel'] == 'postal'

      loc = {
        name:    ppl.css('AddressLine[type="LocationName"]').try(:text),
        address: ppl.css(postal ? 'AddressLine[type="AddressLine2"]' : 'AddressLine[type="Address"]').try(:text),
        city:    ppl.css('AddressLine[type="City"]').try(:text),
        state:   ppl.css('AddressLine[type="State"]').try(:text),
        zip:     ppl_zip.present? ? zip9_to_dashed(ppl_zip) : ppl_zip
      }

      if postal
        loc[:phone] = ppl.css('AddressLine[type="Phone"]').try(:text)
      end

      polling_locations << loc
    end

    polling_locations
  end

end
