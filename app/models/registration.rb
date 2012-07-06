class Registration < ActiveRecord::Base

  include Concern::SerializedAttrs

  scope :stale, lambda { where([ "created_at < ?", 1.day.ago ]) }

  SERVICE_BRANCHES = [ 'Army', 'Air Force', 'Marines', 'Merchant Marine', 'Navy' ]

  serialized_attr :voter_id

  # Eligibility
  serialized_attr :citizen, :old_enough, :residence

  serialized_attr :outside_type
  serialized_attr :service_branch, :service_id, :rank

  serialized_attr :rights_revoked, :rights_revoked_reason
  serialized_attr :rights_restored, :rights_restored_on
  serialized_attr :rights_restored_in

  # Identity
  serialized_attr :first_name, :middle_name, :last_name, :suffix
  serialized_attr :dob, :gender, :ssn, :no_ssn
  serialized_attr :phone, :email

  # Contact info
  serialized_attr :vvr_county_or_city, :vvr_street_number, :vvr_street_name, :vvr_street_type, :vvr_street_suffix, :vvr_apt
  serialized_attr :vvr_town, :vvr_state, :vvr_zip5, :vvr_zip4
  serialized_attr :vvr_is_rural, :vvr_rural
  serialized_attr :vvr_uocava_residence_available, :vvr_uocava_residence_unavailable, :vvr_uocava_residence_unavailable_since
  serialized_attr :mau_address, :mau_address_2, :mau_city, :mau_city_2, :mau_state, :mau_postal_code, :mau_country, :mau_type
  serialized_attr :ma_address,  :ma_address_2,  :ma_city, :ma_state, :ma_zip5, :ma_zip4, :ma_is_same
  serialized_attr :apo_address, :apo_address_2, :apo_1, :apo_2, :apo_zip5
  serialized_attr :has_existing_reg, :er_cancel
  serialized_attr :er_street_number, :er_street_name, :er_street_type, :er_apt,
                  :er_city, :er_state, :er_zip5, :er_zip4, :er_is_rural, :er_rural

  # Options
  serialized_attr :choose_party, :party, :other_party
  serialized_attr :is_confidential_address, :ca_type
  serialized_attr :requesting_absentee, :rab_election,
                  :rab_election_name, :rab_election_date,
                  :absentee_until
  serialized_attr :ab_reason, :ab_street_number,
                  :ab_street_name, :ab_street_type,
                  :ab_apt, :ab_city, :ab_state, :ab_zip5, :ab_zip4, :ab_country,
                  :ab_field_1, :ab_field_2, :ab_time_1, :ab_time_2
  serialized_attr :be_official

  # Complete Registration
  serialized_attr :information_correct, :privacy_agree

  # Current status fields (from server)
  serialized_attr :existing
  serialized_attr :ssn4
  serialized_attr :current_residence
  serialized_attr :current_absentee
  serialized_attr :absentee_for_elections


  def full_name
    [ first_name, middle_name, last_name, suffix ].delete_if(&:blank?).join(' ')
  end

  def absentee?
    self.requesting_absentee == '1'
  end

  def currently_overseas?
    self.current_residence == 'outside'
  end

  def currently_absentee?
    self.current_absentee == '1'
  end

  def currently_domestic_absentee?
    !currently_overseas? && currently_absentee?
  end

  def currently_residential_voter?
    !currently_overseas? && !currently_absentee?
  end

  def uocava?
    self.residence == 'outside'
  end

  def residential?
    !uocava?
  end


  # Initializes the record for the update workflow
  def init_update_to(kind)
    was_uocava = uocava?

    unless kind.blank?
      self.residence           = kind == 'overseas' ? 'outside' : 'in'
      self.requesting_absentee = !!(kind =~ /absentee|overseas/) ? '1' : '0'

      self.rab_election        = nil
      self.rab_election_name   = nil
      self.rab_election_date   = nil
      self.ab_field_1          = nil
      self.ab_field_2          = nil
      self.ab_time_1           = nil
      self.ab_time_2           = nil
      self.ab_reason           = nil
      self.ab_street_number    = nil
      self.ab_street_name      = nil
      self.ab_street_type      = nil
      self.ab_apt              = nil
      self.ab_city             = nil
      self.ab_state            = nil
      self.ab_zip5             = nil
      self.ab_zip4             = nil
      self.ab_country          = nil
    end
  end

  # Existing voter type (used in logs)
  def voter_type
    return nil if voter_id.blank?

    if uocava?
      "Overseas / Military Absentee"
    elsif absentee?
      "Domestic Absentee"
    else
      "Residential Voter"
    end
  end

end
