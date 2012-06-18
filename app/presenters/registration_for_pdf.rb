class RegistrationForPdf < RegistrationDetailsPresenter

  def initialize(reg)
    super reg
    @reg = reg
  end

  # Rights

  def rights_revoked?
    @reg.rights_revoked == 'yes'
  end

  def rights_restored_in
    @reg.rights_restored_in
  end

  def rights_revokation_reason
    rights_revoked_felony? ? 'felony' : 'mental incapacitation'
  end

  def rights_revoked_felony?
    @reg.rights_revoked_reason == 'felony'
  end

  def rights_restored_on
    @reg.rights_restored_on.try(:strftime, "%m/%d/%Y")
  end

  # Identity

  def name
    [ @reg.first_name,
      @reg.middle_name,
      @reg.last_name,
      @reg.suffix ].reject(&:blank?).join(' ')
  end

  def email
    @reg.email
  end

  def ssn
    if !@reg.ssn4.blank?
      "xxx-xx-#{@reg.ssn4}"
    else
      n = @reg.ssn.to_s.gsub(/[^0-9]/, '')
      return '' if n.blank?

      "#{n[0, 3]}-#{n[3, 2]}-#{n[5, 4]}"
    end
  end

  def dob
    @reg.dob.try(:strftime, '%m/%d/%Y')
  end

  def phone
    @reg.phone
  end

  def gender
    @reg.gender
  end

  def party_preference
    "none"
  end

  # Addresses

  def previous_registration?
    @reg.has_existing_reg == 'yes'
  end

  def previous_registration_address
    @er ||= begin
      if @reg.er_is_rural == '1'
        @reg.er_rural
      else
        zip = [ @reg.er_zip5, @reg.er_zip4 ].reject(&:blank?).join('-')
        [ [ [ @reg.er_street_number, @reg.er_apt ].reject(&:blank?).join(' / '), @reg.er_street_name ].reject(&:blank?).join(' '),
          @reg.er_city,
          [ @reg.er_state, zip ].join(' ') ].reject(&:blank?).join(', ')
      end
    end
  end

  def address_confidentiality?
    @reg.is_confidential_address == '1'
  end

  def acp_reason
    Dictionaries::ACP_REASONS[@reg.ca_type]
  end

  # Military / overseas

  def overseas?
    @reg.residence == 'outside'
  end

  def requesting_absentee?
    @reg.requesting_absentee == '1'
  end

  def absentee_status_until
    @reg.absentee_until.strftime("%m/%d/%Y")
  end

  def absentee_type
    I18n.t "outside_type.#{@reg.outside_type}"
  end

  def outside_type_with_details?
    %w( active_duty spouse_active_duty ).include?(@reg.outside_type)
  end

  def military_branch
    @reg.send("service_branch")
  end

  def military_service_id
    @reg.send("service_id")
  end

  def military_rank
    @reg.send("rank")
  end

  def overseas_mailing_address
    if @reg.mau_type == 'non-us'
      abroad_address :mau
    else
      [ @reg.send("apo_address"),
        @reg.send("apo_1"),
        @reg.send("apo_2"),
        @reg.send("apo_zip5") ].reject(&:blank?).join(', ')
    end
  end

  def residental_address_abroad
    abroad_address :raa
  end

  private

  def abroad_address(prefix)
    [ [ @reg.send("#{prefix}_address"), @reg.send("#{prefix}_address_2") ].reject(&:blank?).join(' '),
      [ @reg.send("#{prefix}_city"), @reg.send("#{prefix}_city_2") ].reject(&:blank?).join(' '),
      @reg.send("#{prefix}_state"),
      @reg.send("#{prefix}_postal_code"),
      @reg.send("#{prefix}_country")
    ].reject(&:blank?).join(', ')
  end

  def us_address(prefix)
    if @reg.send("#{prefix}_is_rural") == '1'
      @reg.send("#{prefix}_rural")
    else
      us_address_no_rural(prefix)
    end
  end

  def us_address_no_rural(prefix)
    [ @reg.send("#{prefix}_address"),
      @reg.send("#{prefix}_address_2"),
      @reg.send("#{prefix}_city"),
      @reg.send("#{prefix}_state"),
      [ @reg.send("#{prefix}_zip5"), @reg.send("#{prefix}_zip4") ].reject(&:blank?).join('-')
    ].reject(&:blank?).join(', ')
  end

  def military_prefix
    @reg.outside_type == 'active_duty' ? 'active' : 'spouse'
  end

end
