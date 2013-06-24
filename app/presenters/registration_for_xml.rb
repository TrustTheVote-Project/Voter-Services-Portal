class RegistrationForXML

  extend Forwardable

  def_delegators  :@r, :full_name, :first_name, :middle_name, :last_name, :suffix,
                  :ssn, :created_at, :email, :phone, :dob, :gender,
                  :ca_type,
                  :vvr_address_1, :vvr_address_2, :vvr_town, :vvr_state, :vvr_state,
                  :ma_address, :ma_address_2, :ma_city, :ma_state, :mau_type, :mau_address, :mau_address_2, :mau_city, :mau_city_2,
                  :mau_state, :mau_postal_code, :mau_country,
                  :apo_address, :apo_address_2, :apo_city, :apo_state, :apo_zip5,
                  :as_full_name, :as_first_name, :as_middle_name, :as_last_name, :as_suffix,
                  :as_address, :as_address_2, :as_city, :as_state, :as_zip5, :as_zip4,
                  :pr_status,
                  :pr_full_name, :pr_first_name, :pr_middle_name, :pr_last_name, :pr_suffix,
                  :pr_address, :pr_address_2, :pr_city, :pr_state, :pr_zip5, :pr_zip4, :pr_is_rural, :pr_rural,
                  :rights_felony_restored_in, :rights_felony_restored_on, :rights_mental_restored_on,
                  :ab_reason,
                  :residential?

  def initialize(r)
    @r = r
  end

  def be_official?
    @r.be_official == '1'
  end

  def rights_revoked?
    @r.rights_revoked == '1'
  end

  def overseas?
    @r.uocava? && (/temporary/i =~ @r.outside_type.to_s)
  end

  def military?
    @r.uocava? && (/merchant/i =~ @r.outside_type.to_s)
  end

  def absentee_request?
    @r.requesting_absentee == '1'
  end

  def acp_request?
    @r.is_confidential_address == '1'
  end

  def need_assistance?
    @r.need_assistance == '1'
  end

  def felony?
    @r.rights_felony == '1'
  end

  def mental?
    @r.rights_mental == '1'
  end

  def changing_name?
    @r.pr_status == '1' && @r.full_name != @r.pr_full_name
  end

  def ca_zip
    zip(@r.ca_zip5, @r.ca_zip4)
  end

  def ma_zip
    zip(@r.ma_zip5, @r.ma_zip4)
  end

  def vvr_is_rural?
    @r.vvr_is_rural == '1'
  end

  def pr_is_rural?
    @r.pr_is_rural == '1'
  end

  def pr_zip
    zip(@r.pr_zip5, @r.pr_zip4)
  end

  def as_zip
    zip(@r.as_zip5, @r.as_zip4)
  end

  def vvr_zip
    zip(@r.vvr_zip5, @r.vvr_zip4)
  end

  def ma_is_different?
    @r.ma_is_different == '1'
  end

  def rights_felony_restored?
    @r.rights_felony_restored == '1'
  end

  def rights_mental_restored?
    @r.rights_mental_restored == '1'
  end

  def ab_type
    residential? ? Dictionaries::ABSENCE_REASON_TO_EML310[@r.ab_reason] : @r.outside_type
  end

  def ab_info
    if residential?
      election = @r.rab_election.blank? ? "#{@r.rab_election_name} on #{@r.rab_election_date}" : @r.rab_election
      address  = [
        [ @r.ab_street_number, @r.ab_street_name, @r.ab_street_type ].rjoin(' '),
        @r.ab_apt,
        [ @r.ab_city, @r.ab_state, zip(@r.ab_zip5, @r.ab_zip4) ].rjoin(' '),
        @r.ab_country ].rjoin(', ')
      time = [ @r.ab_time_1, @r.ab_time_2 ].join(' - ')

      [ election, address, @r.ab_field_1, @r.ab_field_2, time ].rjoin(' / ')
    else
      if @r.outside_type == "ActiveDutyMerchantMarineOrArmedForces" ||
         @r.outside_type == "SpouseOrDependentActiveDutyMerchantMarineOrArmedForces"

        [ @r.service_branch, @r.service_id, @r.rank ].rjoin(' ')
      end
    end
  end

  def residence_still_available?
    residential? || @r.vvr_uocava_residence_available == '1'
  end

  def date_of_last_residence
    @r.vvr_uocava_residence_unavailable_since.strftime("%Y-%m-%d")
  end

  private

  def zip(z5, z4)
    [ z5, z4 ].rjoin
  end

end
