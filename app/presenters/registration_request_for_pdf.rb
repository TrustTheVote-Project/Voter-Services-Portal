class RegistrationRequestForPdf

  def initialize(req)
    @req = req
  end

  # Rights

  def felony_rights_revoked?
    @req.convicted != 'false'
  end

  def felony_state
    @req.convicted_in_state
  end

  def felony_restored_on
    @req.convicted_rights_restored_on.try(:strftime, "%m/%d/%Y")
  end

  def mental_rights_revoked?
    @req.mental != 'false'
  end

  def mental_restored_on
    @req.mental_rights_restored_on.try(:strftime, "%m/%d/%Y")
  end

  # Identity

  def name
    [ @req.title,
      @req.first_name,
      @req.middle_name,
      @req.last_name,
      @req.suffix ].reject(&:blank?).join(' ')
  end

  def email
    @req.email
  end

  def ssn
    n = @req.ssn.to_s.gsub(/[^0-9]/, '')
    return '' if n.blank?

    "#{n[0, 3]}-#{n[3, 2]}-#{n[5, 4]}"
  end

  def dob
    @req.dob.try(:strftime, '%m/%d/%Y')
  end

  def phone
    @req.phone
  end

  def gender
    @req.gender
  end

  def party_preference
    "none"
  end

  # Addresses

  def registration_address
    @vvr ||= begin
      if @req.vvr_is_rural == '0'
        if @req.vvr_county_or_city.downcase.include?('county')
          county = @req.vvr_county_or_city
          city = @req.vvr_town_or_city
        else
          county = ''
          city = @req.vvr_county_or_city
        end

        zip = [ @req.vvr_zip5, @req.vvr_zip4 ].reject(&:blank?).join('-')
        [ [ @req.vvr_street_number, @req.vvr_street_name, @req.vvr_street_suffix ].reject(&:blank?).join(' '),
          county,
          city,
          [ 'VA', zip ].join(' ') ].reject(&:blank?).join(', ')
      else
        @req.vvr_rural
      end
    end
  end

  def mailing_address
    if @req.ma_other == '0'
      registration_address
    else
      us_address(:ma)
    end
  end

  def previous_registration?
    @req.has_existing_reg == 'true'
  end

  def previous_registration_address
    us_address(:er)
  end

  def address_confidentiality?
    true
  end

  private

  def us_address(prefix)
    if @req.send("#{prefix}_is_rural")
      @req.send("#{prefix}_rural")
    else
      [ @req.send("#{prefix}_address"),
        @req.send("#{prefix}_address_2"),
        @req.send("#{prefix}_city"),
        @req.send("#{prefix}_state"),
        [ @req.send("#{prefix}_zip5"), @req.send("#{prefix}_zip4") ].reject(&:blank?).join('-')
      ].reject(&:blank?).join(', ')
    end
  end
end
