class Pdf::AbsenteeRequest < Pdf::Form

  # Renders PDF and returns it as a string
  def self.render(reg)
    p = RegistrationForPdf.new(reg)
    render_pdf("Portal_PDF_sbe_absentee_request.pdf") do |pdf|
      set_header(pdf, reg)
      set_part_a(pdf, reg, p)
      set_part_b(pdf, reg, p)
      set_part_c(pdf, reg, p)
      set_part_d(pdf, reg, p)
      set_part_e(pdf, reg, p)
      set_part_f(pdf, reg, p)
    end
  end

  private

  def self.set_header(pdf, reg)
    pdf.set('A_FULL_NAME', reg.full_name)
    if reg.vvr_county_or_city =~ /city/i
      pdf.set('A_CITY_CHECK', 'Y')
    else
      pdf.set('A_COUNTY_CHECK', 'Y')
    end
    pdf.set('A_LOCALITY_NAME', reg.vvr_county_or_city.to_s.upcase.gsub(/\s*(COUNTY|CITY)/, ''))
    set_digital_field(pdf, 'A_SSN', 9, reg.ssn)

    # TODO fill in elections data
  end

  def self.set_part_a(pdf, reg, p)
    pdf.set('A_ABSENTEE_TYPE_CODE', reg.ab_reason)
    pdf.set('A_SUPPORTING_INFO', [ reg.ab_field_1, reg.ab_field_2, p.absence_address, p.absence_time_range ].rjoin(', '))
  end

  def self.set_part_b(pdf, reg, p)
    if reg.ma_is_different == '1'
      # mailing address given
      pdf.set('B_FOLLOWING_CHECK', 'Y')
      pdf.set('B_MAIL_LINE_1', [ reg.ma_address, reg.ma_address_2 ].rjoin(', '))
      pdf.set('B_MAIL_CITY_TOWN', reg.ma_city)
      pdf.set('B_MAIL_STATE', reg.ma_state)
      set_digital_field(pdf, 'B_MAIL_ZIP', 5, reg.ma_zip5)
    elsif p.registration_address_changed?
      # new reg address
      pdf.set('B_NEW_CHECK', 'Y')
    else
      # using current registration
      pdf.set('B_CURRENT_CHECK', 'Y')
    end
  end

  def self.set_part_c(pdf, reg, p)
    pdf.set('C_ASSIST_CHECK', 'Y') if reg.need_assistance == '1'
  end

  def self.set_part_d(pdf, reg, p)
    pdf.set('D_FULL_NAME', reg.full_name)
    set_date_field(pdf, 'D_SIG_DATE', Time.now)
    set_digital_field(pdf, 'D_SSN', 9, reg.ssn)
    set_digital_field(pdf, 'D_YOB', 4, reg.dob.year.to_s) unless reg.dob.blank?
    set_digital_field(pdf, 'D_PHONE', 10, reg.phone.gsub(/[^0-9]/, '')) unless reg.phone.blank?
    pdf.set('D_EMAIL_OR_FAX', reg.email)

    pdf.set('D_RES_LINE_1', reg.vvr_address_1)
    pdf.set('D_RES_APT_UNIT', reg.vvr_address_2)
    pdf.set('D_RES_CITY_TOWN', reg.vvr_town)
    set_digital_field(pdf, 'D_RES_ZIP', 5, reg.vvr_zip5)

    pdf.set('D_RES_CHANGE_CHECK', 'Y') if p.name_changed? || p.registration_address_changed?
  end

  def self.set_part_e(pdf, reg, p)
    pdf.set('E_NAME_ASSISTANT', reg.as_full_name)
    pdf.set('E_ADDRESS_ASSISTANT', [ reg.as_address, reg.as_address_2 ].rjoin(', '))
    pdf.set('E_CITY_TOWN_ASSISTANT', reg.as_city)
    pdf.set('E_STATE_ASSISTANT', reg.as_state)
    set_digital_field(pdf, 'E_ZIP_ASSISTANT', 5, reg.as_zip5)
  end

  def self.set_part_f(pdf, reg, p)
    pdf.set('F_NAME', p.name)
    pdf.set('F_FORMER_NAME', p.previous_name) if p.name_changed?

    if p.registration_address_changed?
      pdf.set('F_NEW_ADDRESS_LINE1', reg.vvr_address_1)
      pdf.set('F_APT_UNIT', reg.vvr_address_2)
      pdf.set('F_CITY_TOWN', reg.vvr_town)
      set_digital_field(pdf, 'F_ZIP', 5, reg.vvr_zip5)
    end
    pdf.set('F_OLD_ADDRESS', p.old_registration_address)

    if reg.ma_is_different == '1'
      pdf.set('F_MAILING_ADDRESS', p.us_address_no_rural(:ma))
    end
  end

end
