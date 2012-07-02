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

  def residential?
    !overseas?
  end

  def overseas?
    @reg.residence == 'outside'
  end

  def was_overseas?
    previous_data[:residence] == 'outside'
  end

  def subheaders
    if overseas?
      # Became overseas/military
      [ "Update Form and Absentee Request", "Overseas/Military Voter" ]
    elsif was_overseas?
      # Was overseas/military
      if requesting_absentee?
        [ "Update Form and Absentee Request", "Returning Overseas/Military Voter" ]
      else
        [ "Update Form", "Returning Overseas/Military Voter" ]
      end
    elsif requesting_absentee?
      # Domestic absentee
      [ "Update Form and Absentee Request", nil ]
    else
      # Residential voter
      [ "Update Form", nil ]
    end
  end

  def requesting_absentee?
    @reg.requesting_absentee == '1'
  end

  def absentee_status_until
    Date.parse(@reg.absentee_until).strftime("%m/%d/%Y")
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

  def residental_address_abroad
    abroad_address :raa
  end

  def mailing_address_availability
    if @reg.vvr_uocava_residence_available == '0'
      "My last date of residence at the above address was #{@reg.vvr_uocava_residence_unavailable_since.strftime("%m/%d/%Y")}"
    else
      "My Virginia residence is still available to me"
    end
  end

  # Misc

  def being_official?
    @reg.be_official == '1'
  end

  private

  def us_address(prefix)
    if @reg.send("#{prefix}_is_rural") == '1'
      @reg.send("#{prefix}_rural")
    else
      us_address_no_rural(prefix)
    end
  end

  def military_prefix
    @reg.outside_type == 'active_duty' ? 'active' : 'spouse'
  end

  def previous_data
    @reg.previous_data || {}
  end
end
