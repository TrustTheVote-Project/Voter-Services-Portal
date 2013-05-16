class RegistrationForPdf < RegistrationDetailsPresenter

  def_delegators :@reg, :requesting_absentee?, :no_form_changes?, :ssn4

  def initialize(reg)
    super reg
    @reg = reg
    @er = {}
  end

  def registrar_address
    locality = @reg.poll_locality || @reg.vvr_county_or_city
    o = Office.where(locality: locality).first
    if o
      a = o.address.split("\n")
      a.pop # remove phone

      ([ "#{locality} General Registrar" ] + a).join("<br/>").html_safe
    end
  end

  # Rights

  def rights_revoked?
    @reg.rights_revoked == '1'
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

  def name(d = :data)
    d = @reg.send(d)
    [ d[:first_name],
      d[:middle_name],
      d[:last_name],
      d[:suffix] ].reject(&:blank?).join(' ')
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

  def gender
    @reg.gender
  end

  def party_preference(d = :data)
    d = @reg.send(d)
    d[:choose_party] != '1' ? nil : d[:party] == 'other' ? d[:other_party] : d[:party]
  end

  # Addresses

  def existing_registration?(d = :data)
    @reg.send(d)[:has_existing_reg] == '1'
  end

  def existing_registration_address(d = :data)
    @er[d] ||= begin
      data = @reg.send(d)
      if data[:er_is_rural] == '1'
        data[:er_rural]
      else
        zip = [ data[:er_zip5], data[:er_zip4] ].rjoin('-')
        [ [ data[:er_street_number], data[:er_street_name] ].rjoin(' '),
          data[:er_apt],
          data[:er_city],
          [ data[:er_state], zip ].join(' ') ].rjoin(', ')
      end
    end
  end

  def address_confidentiality?(d = :data)
    @reg.send(d)[:is_confidential_address] == '1'
  end

  def acp_reason(d = :data)
    key = @reg.send(d)[:ca_type]
    "#{key}: #{I18n.t("options.ac.reasons.#{key}")}"
  end

  def acp_pobox(d = :data)
    d = @reg.send(d)
    po = d[:ca_po_box].blank? ? '' : "P.O. Box #{d[:ca_po_box]}"
    [ po, [ d[:ca_city], 'VA', [ d[:ca_zip5], d[:ca_zip4] ].rjoin('-') ].rjoin(' ') ].join(', ')
  end

  # Military / overseas

  def residential?
    !overseas?
  end

  def was_overseas?
    previous_data[:residence] == 'outside'
  end

  def data_update_page_headers
    if overseas?
      # Became overseas/military
      [ "Alternative Federal Postcard Application", "Overseas/Military Voter" ]
    elsif was_overseas?
      # Was overseas/military
      [ "Voter Record Update Request", "Returning Overseas/Military Voter" ]
    else
      # Residential voter
      [ "Voter Record Update Request", nil ]
    end
  end

  def absentee_request_page_headers(combined = false)
    if overseas?
      # Overseas/military
      return [ "Alternative Federal Postcard Application", "Overseas/Military Voter" ]
    end

    sh = was_overseas? ? "Returning Overseas/Military Voter" : nil
    h  = "Absentee Request"

    if combined
      if !requesting_absentee?
        h = "Voter Record Update Request"
      elsif !no_form_changes?
        h = "Absentee Request and Voter Record Update Request"
      end
    end

    [ h, sh ]
  end

  def absentee_status_until
    Date.parse(@reg.absentee_until).strftime("%m/%d/%Y")
  end

  def absentee_type
    t = I18n.t "outside_type.#{@reg.outside_type}"
    c = Dictionaries::OVERSEAS_ABSENCE_CODES[@reg.outside_type]
    "#{t} (#{c})"
  end

  def outside_type_with_details?
    /merchant/i =~ @reg.outside_type.to_s
  end

  def absence_reason
    "#{Dictionaries::ABSENCE_REASONS[@reg.ab_reason]} (#{@reg.ab_reason})"
  end

  def absence_locality
    cc = @reg.vvr_county_or_city
    cc.blank? ? @reg.vvr_town : cc
  end

  def absentee_election
    if @reg.rab_election == 'other'
      "#{@reg.rab_election_name} on #{@reg.rab_election_date}"
    else
      @reg.rab_election
    end
  end

  def absence_fields
    @absence_fields ||= begin
      f1_label = Dictionaries::ABSENCE_F1_LABEL[@reg.ab_reason]
      f2_label = Dictionaries::ABSENCE_F2_LABEL[@reg.ab_reason]

      fields = []
      fields << { columns: 1, value: @reg.ab_field_1, label: f1_label } if f1_label
      fields << { columns: 1, value: @reg.ab_field_2, label: f2_label } if f2_label

      fields
    end

    @absence_fields
  end

  def absence_address
    data = @reg.data

    zip = [ data[:ab_zip5], data[:ab_zip4] ].rjoin('-')
    [ [ data[:ab_street_number], data[:ab_street_name], data[:ab_street_type] ].rjoin(' '),
      data[:ab_apt],
      data[:ab_city],
      [ data[:ab_state], zip, data[:ab_country] ].join(' ') ].rjoin(', ')
  end

  def absence_time_range
    "#{@reg.ab_time_1.strftime("%H:%M")} - #{@reg.ab_time_2.strftime("%H:%M")}"
  rescue
    nil
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

  def mailing_address_availability(d = :data)
    data = @reg.send(d)
    if data[:vvr_uocava_residence_available] == '0'
      "My last date of residence at the above address was #{data[:vvr_uocava_residence_unavailable_since].strftime("%m/%d/%Y")}"
    else
      "My Virginia residence is still available to me"
    end
  end

  # Misc

  def being_official?
    @reg.be_official == '1'
  end

  def previous_name
    name(:previous_data)
  end

  def previous_registration_address
    registration_address(:previous_data)
  end

  def previous_mailing_address
    update_mailing_address(:previous_data)
  end

  def residence_still_available?
    @reg.vvr_uocava_residence_available == '1'
  end

  def residence_unavailable_since
    @reg.vvr_uocava_residence_unavailable_since.strftime("%B %d, %Y")
  end

  # Changes

  def name_changed?
    previous_name != name
  end

  def email_changed?
    @reg.email.to_s != previous_data[:email].to_s
  end

  def phone_changed?
    @reg.phone.to_s != previous_data[:phone].to_s
  end

  def party_changed?
    party_preference != party_preference(:previous_data)
  end

  def registration_address_changed?
    registration_address != previous_registration_address
  end

  def mailing_address_changed?
    mailing_address != previous_mailing_address
  end

  def existing_registration_changed?
    (existing_registration? && !existing_registration?(:previous_data)) ||
    (existing_registration_address != existing_registration_address(:previous_data))
  end

  def address_confidentiality_changed?
    (address_confidentiality? && !address_confidentiality?(:previous_data)) ||
    (acp_reason != acp_reason(:previous_data))
  end

  def mailing_address_availability_changed?
    mailing_address_availability != mailing_address_availability(:previous_data)
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
    @reg.outside_type == 'ActiveDutyMerchantMarineOrArmedForces' ? 'active' : 'spouse'
  end

  def previous_data
    @reg.previous_data || {}
  end
end
