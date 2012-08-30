r = RegistrationForXML.new @registration
c = AppConfig['xml']

xml.instruct!
xml.EML 'SchemaVersion'  => "7.0",
        'Id'             => "310",
        'xmlns'          => "urn:oasis:names:tc:evs:schema:eml",
        'xmlns:xsi'      => "http://www.w3.org/2001/XMLSchema-instance",
        'xmlns:xsd'      => "http://www.w3.org/2001/XMLSchema" do

  xml.EMLHeader do
    xml.TransactionId 310
    xml.OfficialStatusDetail do
      xml.OfficialStatus 'approved'
      xml.StatusDate Date.today.strftime("%Y-%m-%d")
    end
  end

  xml.VoterRegistration do
    xml.Voter do
      xml.Source Role: 'sender' do
        xml.Name      c['source_name']
        xml.IdValue   806000539
      end

      xml.VoterIdentification do
        xml.VoterName do
          xml.PersonFullName    r.full_name, { 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" }
          xml.PersonNameDetail 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" do
            xml.GivenName       r.first_name
            xml.MiddleName      r.middle_name
            xml.FamilyName      r.last_name
            xml.NameSuffixText  r.suffix
          end
        end

        electoral_address xml, r

        if r.has_existing_reg?
          o = { status: 'previous' }
          o[:type] = 'Rural' if r.er_is_rural?

          xml.PreviousElectoralAddress o do
            if r.er_is_rural?
              xml.FreeTextAddress 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" do
                xml.AddressLine r.er_rural
              end
            else
              xml.PostalAddress 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" do
                xml.Thoroughfare r.er_thoroughfare,
                  type:   r.er_street_type,
                  number: r.er_street_number,
                  name:   r.er_street_name
                xml.Locality r.er_city, type: 'Town'
                xml.AdministrativeArea r.er_state, type: 'StateCode'
                xml.PostCode [ r.er_zip5, r.er_zip4 ].join(''), type: 'ZipCode'
                xml.Country "United States of America", code: "USA"
              end
            end
          end
        end

        xml.VoterPhysicalID r.ssn, IdType: 'SSN' unless r.ssn.blank?
      end

      xml.VoterInformation do
        xml.Contact do
          mailing_address xml, r
          xml.Email r.email unless r.email.blank?

          unless r.email.blank?
            xml.Telephone do
              xml.Number r.phone
            end
          end
        end

        xml.DateOfBirth r.dob.try(:strftime, "%Y-%m-%d")
        xml.Gender r.gender
        xml.CheckBox 'yes', Type: 'Eighteenplus'
        xml.CheckBox 'yes', Type: 'Citizen'
        xml.CheckBox yn(r.be_official?), Type: 'ElectionOfficialInterest'
        xml.CheckBox 'yes', Type: 'RegistrationStatement'
        xml.CheckBox 'yes', Type: 'PrivacyNotice'

        xml.CheckBox yn(r.rights_revoked?), Type: 'VotingRightsRevoked'
        xml.CheckBox yn(r.overseas?), Type: 'Overseas'
        xml.CheckBox yn(r.military?), Type: 'Military'
        xml.CheckBox yn(r.absentee_request?), Type: 'AbsenteeRequest'
        xml.CheckBox yn(r.acp_request?), Type: 'AddressConfidentialityRequest'
        xml.CheckBox yn(r.residence_still_available?), Type: 'ResidenceStillAvailable'

        xml.FurtherInformation do
          order = 1

          if r.felony?
            xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: 'Felony', Seqn: order do
              xml.Felony  "yes",
                          "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                          "RightsRestored"     => yn(r.rights_restored?),
                          "ConvictionState"    => r.rights_restored_in,
                          "RestoredDate"       => r.rights_restored_on,
                          "xmlns"              => ''
            end
            order += 1
          end

          if r.mental?
            xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: "Incapacitated", Seqn: order do
              xml.Incapacitated "yes",
                                "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                                "RightsRestored"     => yn(r.rights_restored?),
                                "RestoredDate"       => r.rights_restored_on,
                                "xmlns"              => ""
            end
            order += 1
          end

          if r.acp_request?
            xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: "Confidential", Seqn: order do
              xml.Confidentiality "yes",
                "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                "type"               => r.ca_type,
                "xmlns"              => ""
              xml.SubstitueAddress status: "previous" do
                xml.PostalAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
                  xml.Thoroughfare "P.O. Box #{r.ca_po_box}", type: "PObox", number: r.ca_po_box
                  xml.Locality r.ca_city, type: "Town"
                  xml.PostCode r.ca_zip, type: "ZipCode"
                  xml.Country "United States of America", code: "USA"
                end
              end
            end
            order += 1
          end

          if r.absentee_request?
            xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: "AbsenteeRequest", Seqn: order do
              xml.AbsenteeType r.ab_type,
                "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                "xmlns"              => ""
              xml.AbsenteeInfo r.ab_info
            end
            order += 1
          end

          unless r.residence_still_available?
            xml.Message r.date_of_last_residence, DisplayOrder: order.to_s.rjust(4, '0'), Type: 'DateofLastResidence', Seqn: order
            order += 1
          end
        end
      end
    end

    xml.DateTimeSubmitted r.created_at.utc.strftime("%Y-%m-%dT%H:%M:%S.0000-00:00")
  end
end
