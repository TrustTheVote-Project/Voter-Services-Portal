class Pdf::StateAbsenteeRequest < Pdf::Form

  # Renders PDF and returns it as a string
  def self.render(reg)
    p = RegistrationForPdf.new(reg)
    render_pdf 'state_absentee_pdf' do |pdf|
      set_part_1 pdf, reg
      set_part_2 pdf, reg, p
      set_part_3 pdf, reg, p
      set_part_4 pdf, reg, p
      set_part_5 pdf, reg
      set_part_6 pdf, reg, p
      set_part_7 pdf, reg, p
      set_part_8 pdf, reg, p
      set_part_9 pdf, reg, p
    end
  end

  private

  def self.set_part_1(pdf, reg)
    pdf.set '1_LAST_NAME', reg.last_name
    pdf.set '1_FIRST_NAME', reg.first_name
    pdf.set '1_MIDDLE_NAME', reg.middle_name
    pdf.set '1_SUFFIX', reg.suffix
    set_digital_field pdf, '1_SSN', 9, reg.ssn
  end

  def self.set_part_2(pdf, reg, p)
    type = p.absentee_election_type
    pdf.set "2_ELECTION_#{type}", "Y"
    set_short_date_field pdf, "2_ELECTION_DATE", p.absentee_election_date

    if reg.vvr_county_or_city =~ /city/i
      pdf.set('2_LOCALITY_CITY', 'Y')
    else
      pdf.set('2_LOCALITY_COUNTY', 'Y')
    end
    pdf.set('2_LOCALITY_NAME', reg.vvr_county_or_city.to_s.upcase.gsub(/\s*(COUNTY|CITY)/, ''))
  end

  def self.set_part_3(pdf, reg, p)
    r = reg.ab_reason || ''
    pdf.set('3_REASON_CODE_1', r[0])
    pdf.set('3_REASON_CODE_2', r[1])
    pdf.set('3_SUPPORTING_INFO', [ reg.ab_field_1, reg.ab_field_2, p.absence_address, p.absence_time_range ].rjoin(', '))
  end

  def self.set_part_4(pdf, reg, p)
    set_digital_field(pdf, '4_YOB', 4, reg.dob.year.to_s) unless reg.dob.blank?
    set_digital_field(pdf, '4_PHONE', 10, reg.phone.gsub(/[^0-9]/, '')) unless reg.phone.blank?
    pdf.set '4_EMAIL_OR_FAX', reg.email
  end

  def self.set_part_5(pdf, reg)
    pdf.set '5_ADDRESS', reg.vvr_address_1
    pdf.set '5_APT', reg.vvr_address_2
    pdf.set '5_CITY', reg.vvr_town
    set_digital_field pdf, '5_ZIP', 5, reg.vvr_zip5
  end

  def self.set_part_6(pdf, reg, p)
    if reg.uocava?
      pdf.set '6_ADDRESS_MA', 'Y'
      if reg.mau_type == 'non-us'
        pdf.set '6_ADDRESS', reg.mau_address
        pdf.set '6_APT', reg.mau_address_2
        pdf.set '6_CITY', [ reg.mau_city, reg.mau_city_2 ].rjoin(' ')
        pdf.set '6_STATE', [ reg.mau_state, reg.mau_country ].rjoin(', ')
        set_digital_field pdf, '6_ZIP', 9, reg.mau_postal_code.to_s
      else
        pdf.set '6_ADDRESS', reg.apo_address
        pdf.set '6_APT', reg.apo_address_2
        pdf.set '6_CITY', reg.apo_city
        pdf.set '6_STATE', reg.apo_state
        set_digital_field pdf, '6_ZIP', 5, reg.apo_zip5
      end
    else
      if reg.ma_is_different == '1'
        pdf.set '6_ADDRESS_MA', 'Y'
        pdf.set '6_ADDRESS', reg.ma_address
        pdf.set '6_APT', reg.ma_address_2
        pdf.set '6_CITY', reg.ma_city
        pdf.set '6_STATE', reg.ma_state
        set_digital_field pdf, '6_ZIP', 9, [ reg.ma_zip5, reg.ma_zip4 ].rjoin('')
      else
        pdf.set '6_ADDRESS_RES', 'Y'
      end
    end
  end

  def self.set_part_7(pdf, reg, p)
    return unless reg.previous_data?

    if p.name_changed?
      pdf.set '7_FORMER_NAME', p.previous_address
    end

    if p.registration_address_changed?
      pdf.set '7_FORMER_ADDRESS', p.old_registration_address
    end

    # TODO how to fill "moved on" date?
  end

  def self.set_part_8(pdf, reg, p)
    pdf.set('8_ASSISTANCE', 'Y') unless [ reg.as_full_name, reg.as_address, reg.as_address_2, reg.as_city, reg.as_state, reg.as_zip5 ].reject(&:blank?).empty?
  end

  def self.set_part_9(pdf, reg, p)
    pdf.set '9_NAME', reg.as_full_name
    pdf.set '9_ADDRESS', reg.as_address
    pdf.set '9_APT', reg.as_address_2
    pdf.set '9_CITY', reg.as_city
    pdf.set '9_STATE', reg.as_state
    set_digital_field pdf, '9_ZIP', 5, reg.as_zip5
  end

end
