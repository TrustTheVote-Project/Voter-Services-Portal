require 'digest/sha1'

class Eml310Builder

  # builds EML310 for the given registration object
  def self.build(registration, xml)
    r = RegistrationForXML.new registration
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
          xml.OfficialStatus 'submitted'
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

            if r.changing_name?
              xml.PreviousName do
                xml.PersonFullName    r.pr_full_name, { 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" }
                xml.PersonNameDetail 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" do
                  xml.GivenName       r.pr_first_name
                  xml.MiddleName      r.pr_middle_name
                  xml.FamilyName      r.pr_last_name
                  xml.NameSuffixText  r.pr_suffix
                end
              end
            end

            electoral_address xml, r

            if r.pr_status == '1'
              o = { status: 'previous' }
              o[:type] = 'Rural' if r.pr_is_rural?

              xml.PreviousElectoralAddress o do
                xml.PostalAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
                  xml.Thoroughfare        r.pr_address
                  xml.OtherDetail         r.pr_address_2 unless r.pr_address_2.blank?
                  xml.OtherDetail         r.pr_city, type: 'City'
                  xml.AdministrativeArea  r.pr_state, type: 'StateCode'
                  xml.PostCode            r.pr_zip, type: 'ZipCode'
                  xml.Country             'US'
                end
              end
            end

            xml.VoterPhysicalID r.ssn, IdType: 'SSN' if r.ssn.present?
            xml.VoterPhysicalID registration.dmv_id, IdType: 'StateIDnumber' if registration.dmv_id.present? && !registration.existing
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
            xml.Gender r.gender.try(:downcase)
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
            xml.CheckBox yn(r.need_assistance?), Type: 'RequiresAssistanceToVote'
            xml.CheckBox yn(r.residence_still_available?), Type: 'ResidenceStillAvailable'

            xml.FurtherInformation do
              order = 1

              if r.felony?
                xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: 'Felony', Seqn: order do
                  xml.Felony  "yes",
                              "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                              "RightsRestored"     => yn(r.rights_felony_restored?),
                              "ConvictionState"    => r.rights_felony_restored_in,
                              "RestoredDate"       => r.rights_felony_restored_on,
                              "xmlns"              => 'http://sbe.virginia.gov/EmlExtension'
                end
                order += 1
              end

              if r.mental?
                xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: "Incapacitated", Seqn: order do
                  xml.Incapacitated "yes",
                                    "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                                    "RightsRestored"     => yn(r.rights_mental_restored?),
                                    "RestoredDate"       => r.rights_mental_restored_on,
                                    "xmlns"              => "http://sbe.virginia.gov/EmlExtension"
                end
                order += 1
              end

              if r.acp_request?
                xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: "Confidential", Seqn: order do
                  xml.Confidentiality "yes",
                    "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                    "type"               => r.ca_type,
                    "xmlns"              => "http://sbe.virginia.gov/EmlExtension"
                end
                order += 1
              end

              if r.absentee_request?
                xml.Message DisplayOrder: order.to_s.rjust(4, '0'), Type: "AbsenteeRequest", Seqn: order do
                  xml.AbsenteeType r.ab_type,
                    "xsi:schemaLocation" => "http://sbe.virginia.gov EmlExtension.xsd",
                    "xmlns"              => "http://sbe.virginia.gov/EmlExtension"
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

        if r.assistant_details_present?
          xml.RegistrationAssistant do
            xml.AssistantName do
              xml.PersonFullName    r.as_full_name, { 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" }
              xml.PersonNameDetail 'xmlns' => "urn:oasis:names:tc:ciq:xnl:4" do
                xml.GivenName       r.as_first_name
                xml.MiddleName      r.as_middle_name
                xml.FamilyName      r.as_last_name
                xml.NameSuffixText  r.as_suffix
              end
            end
            xml.AssistantAddress status: 'current' do
              xml.FreeTextAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
                address_lines xml, [
                  [ 'AddressLine1',  r.as_address ],
                  [ 'AddressLine2',  r.as_address_2 ],
                  [ 'City',          r.as_city ],
                  [ 'State',         r.as_state ],
                  [ 'Zip',           r.as_zip ] ]
              end
            end
          end
        end

        xml.DateTimeSubmitted r.created_at.utc.strftime("%Y-%m-%dT%H:%M:%S.0000-00:00")
      end
    end
  end

  def self.yn(v)
    v ? 'yes' : 'no'
  end

  def self.electoral_address(xml, r, tag_name = 'ElectoralAddress')
    o = {}
    o[:type] = 'Rural' if r.vvr_is_rural?

    xml.tag! tag_name, o do
      xml.PostalAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
        xml.Thoroughfare        r.vvr_address_1
        xml.OtherDetail         r.vvr_address_2 unless r.vvr_address_2.blank?
        xml.Locality            r.vvr_county_or_city
        xml.OtherDetail         r.vvr_town, type: 'City'
        xml.AdministrativeArea  r.vvr_state, type: 'StateCode'
        xml.PostCode            r.vvr_zip, type: 'ZipCode'
        xml.Country             'US'
      end
    end
  end

  def self.mailing_address(xml, r)
    if r.residential?
      if r.ma_is_different?
        xml.MailingAddress do
          xml.FreeTextAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
            address_lines xml, [
              [ 'AddressLine1',  r.ma_address ],
              [ 'AddressLine2',  r.ma_address_2 ],
              [ 'City',          r.ma_city ],
              [ 'State',         r.ma_state ],
              [ 'Zip',           r.ma_zip ] ]
          end
        end
      end
    else
      xml.MailingAddress status: 'current' do
        xml.FreeTextAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
          if r.mau_type == 'non-us'
            address_lines xml, [
              [ 'AddressLine1',   r.mau_address ],
              [ 'AddressLine2',   r.mau_address_2 ],
              [ 'City',           [ r.mau_city, r.mau_city_2 ].reject(&:blank?).join(' ') ],
              [ 'State',          r.mau_state ],
              [ 'PostalCode',     r.mau_postal_code ],
              [ 'Country',        r.mau_country ] ]
          else
            address_lines xml, [
              [ 'AddressLine1',   r.apo_address ],
              [ 'AddressLine2',   r.apo_address_2 ],
              [ 'City',           r.apo_city ],
              [ 'State',          r.apo_state ],
              [ 'PostalCode',     r.apo_zip5 ],
              [ 'Country',        'US' ] ]
          end
        end
      end
    end
  end

  def self.address_lines(xml, lines)
    seqn = 1
    lines.each do |type, value|
      next if value.blank?

      o = { seqn: seqn.to_s.rjust(4, '0') }
      o[:type] = type if type

      xml.AddressLine value, o
      seqn += 1
    end
  end

end
