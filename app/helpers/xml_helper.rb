require 'digest/sha1'

module XmlHelper

  def yn(v)
    v ? 'yes' : 'no'
  end

  def electoral_address(xml, r, tag_name = 'ElectoralAddress')
    o = { status: 'current' }
    o[:type] = 'Rural' if r.vvr_is_rural?

    xml.tag! tag_name, o do
      if r.vvr_is_rural?
        xml.FreeTextAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
          xml.AddressLine r.vvr_rural
        end
      else
        xml.PostalAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
          xml.Thoroughfare        r.vvr_thoroughfare, type: r.vvr_street_type, number: r.vvr_street_number, name: r.vvr_street_name
          xml.OtherDetail         r.vvr_apt unless r.vvr_apt.blank?
          xml.Locality            r.vvr_town, type: 'Town'
          xml.AdministrativeArea  r.vvr_state, type: 'StateCode'
          xml.PostCode            r.vvr_zip, type: 'ZipCode'
          xml.Country             'United States of America', code: 'USA'
        end
      end
    end
  end

  def mailing_address(xml, r)
    if r.residential?
      if r.ma_is_same?
        electoral_address(xml, r, 'MailingAddress')
      else
        xml.MailingAddress status: 'current' do
          xml.FreeTextAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
            address_lines xml, [
              [ 'MailingAddressLine1',  r.ma_address ],
              [ 'MailingAddressLine2',  r.ma_address_2 ],
              [ 'MailingCity',          r.ma_city ],
              [ 'MailingState',         r.ma_state ],
              [ 'MailingZip',           r.ma_zip ] ]
          end
        end
      end
    else
      xml.MailingAddress status: 'current' do
        xml.FreeTextAddress xmlns: "urn:oasis:names:tc:ciq:xal:4" do
          if r.mau_type == 'non-us'
            address_lines xml, [
              [ nil,          r.mau_address ],
              [ nil,          r.mau_address_2 ],
              [ 'City',       [ r.mau_city, r.mau_city_2 ].reject(&:blank?).join(' ') ],
              [ 'State',      r.mau_state ],
              [ 'PostalCode', r.mau_postal_code ],
              [ 'Country',    r.mau_country ] ]
          else
            address_lines xml, [
              [ nil,          r.apo_address ],
              [ nil,          r.apo_address_2 ],
              [ 'City',       r.apo_1 ],
              [ 'State',      r.apo_2 ],
              [ 'PostalCode', r.apo_zip5 ],
              [ 'Country',    'United States' ] ]
          end
        end
      end
    end
  end

  private

  def address_lines(xml, lines)
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
