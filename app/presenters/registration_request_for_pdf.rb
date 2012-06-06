class RegistrationRequestForPdf

  def initialize(req)
    @req = req
  end

  # Rights

  def rights_revoked?
    @req.rights_revoked == 'yes'
  end

  def rights_restored_in
    @req.rights_restored_in
  end

  def rights_revokation_reason
    rights_revoked_felony? ? 'felony' : 'mental incapacitation'
  end

  def rights_revoked_felony?
    @req.rights_revoked_reason == 'felony'
  end

  def rights_restored_on
    @req.rights_restored_on.try(:strftime, "%m/%d/%Y")
  end

  # Identity

  def name
    [ @req.first_name,
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
          city = @req.vvr_town
        else
          county = ''
          city = @req.vvr_county_or_city
        end

        zip = [ @req.vvr_zip5, @req.vvr_zip4 ].reject(&:blank?).join('-')
        [ [ [ @req.vvr_street_number, @req.vvr_apt ].reject(&:blank?).join(' / '), @req.vvr_street_name, @req.vvr_street_suffix ].reject(&:blank?).join(' '),
          county,
          city,
          [ 'VA', zip ].join(' ') ].reject(&:blank?).join(', ')
      else
        @req.vvr_rural
      end
    end
  end

  def mailing_address
    if overseas?
      overseas_mailing_address
    else
      domestic_mailing_address
    end
  end

  def domestic_mailing_address
    if @req.ma_is_same == 'yes'
      registration_address
    else
      us_address_no_rural(:ma)
    end
  end

  def previous_registration?
    @req.has_existing_reg == 'yes'
  end

  def previous_registration_address
    @er ||= begin
      if @req.er_is_rural == '1'
        @req.er_rural
      else
        zip = [ @req.er_zip5, @req.er_zip4 ].reject(&:blank?).join('-')
        [ [ [ @req.er_street_number, @req.er_apt ].reject(&:blank?).join(' / '), @req.er_street_name ].reject(&:blank?).join(' '),
          @req.er_city,
          [ @req.er_state, zip ].join(' ') ].reject(&:blank?).join(', ')
      end
    end
  end

  def address_confidentiality?
    @req.is_confidential_address == '1'
  end

  def acp_reason
    @req.ca_type
  end

  # Military / overseas

  def overseas?
    @req.residence == 'outside'
  end

  def requesting_absentee?
    @req.requesting_absentee == '1'
  end

  def absentee_status_until
    @req.absentee_until.strftime("%m/%d/%Y")
  end

  def absentee_type
    I18n.t "outside_type.#{@req.outside_type}"
  end

  def outside_type_with_details?
    %w( active_duty spouse_active_duty ).include?(@req.outside_type)
  end

  def military_branch
    @req.send("service_branch")
  end

  def military_service_id
    @req.send("service_id")
  end

  def military_rank
    @req.send("rank")
  end

  def overseas_mailing_address
    if @req.mau_type == 'non-us'
      abroad_address :mau
    else
      [ @req.send("apo_address"),
        @req.send("apo_1"),
        @req.send("apo_2"),
        @req.send("apo_zip5") ].reject(&:blank?).join(', ')
    end
  end

  def residental_address_abroad
    abroad_address :raa
  end

  private

  def abroad_address(prefix)
    [ [ @req.send("#{prefix}_address"), @req.send("#{prefix}_address_2") ].reject(&:blank?).join(' '),
      [ @req.send("#{prefix}_city"), @req.send("#{prefix}_city_2") ].reject(&:blank?).join(' '),
      @req.send("#{prefix}_state"),
      @req.send("#{prefix}_postal_code"),
      @req.send("#{prefix}_country")
    ].reject(&:blank?).join(', ')
  end

  def us_address(prefix)
    if @req.send("#{prefix}_is_rural") == '1'
      @req.send("#{prefix}_rural")
    else
      us_address_no_rural(prefix)
    end
  end

  def us_address_no_rural(prefix)
    [ @req.send("#{prefix}_address"),
      @req.send("#{prefix}_address_2"),
      @req.send("#{prefix}_city"),
      @req.send("#{prefix}_state"),
      [ @req.send("#{prefix}_zip5"), @req.send("#{prefix}_zip4") ].reject(&:blank?).join('-')
    ].reject(&:blank?).join(', ')
  end

  def military_prefix
    @req.outside_type == 'active_duty' ? 'active' : 'spouse'
  end

end
