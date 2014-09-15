class Pdf::Fpca < Pdf::Form

  # Renders PDF and returns it as a string
  def self.render(reg)
    p = RegistrationForPdf.new(reg)
    render_pdf "fpca_pdf" do |pdf|
      set_part_1(pdf, reg, p)
      set_part_2(pdf, reg, p)
      set_part_3(pdf, reg, p)
      set_part_4(pdf, reg, p)
      set_part_5(pdf, reg, p)
      set_part_6(pdf, reg, p)
      set_part_7(pdf, reg, p)
      set_part_8(pdf, reg, p)
      set_part_9(pdf, reg, p)
      set_postage(pdf, reg, p)
    end
  end

  private

  def self.set_part_1(pdf, reg, p)
    if reg.outside_type == 'ActiveDutyMerchantMarineOrArmedForces'
      pdf.set('1_MEMBER_CHECK', 'Y')
    elsif reg.outside_type == 'SpouseOrDependentActiveDutyMerchantMarineOrArmedForces'
      pdf.set('1_SPOUSE_CHECK', 'Y')
    elsif reg.outside_type == 'TemporaryResideOutside'
      pdf.set('1_TEMPORARY_CHECK', 'Y')
    end
  end

  def self.set_part_2(pdf, reg, p)
    pdf.set('2_PARTY_NAME', p.party_preference)
  end

  def self.set_part_3(pdf, reg, p)
    pdf.set('3_LAST_NAME', reg.last_name)
    pdf.set('3_MIDDLE_NAME', reg.middle_name)
    pdf.set('3_FIRST_NAME', reg.first_name)
    pdf.set('3_SUFFIX', reg.suffix)
    pdf.set('3_PREVIOUS_NAME', reg.pr_full_name)
  end

  def self.set_part_4(pdf, reg, p)
    if reg.gender =~ /F/
      pdf.set('4_F_CHECK', 'Y')
    else
      pdf.set('4_M_CHECK', 'Y')
    end

    set_date_field(pdf, '4_DOB', reg.dob)
    pdf.set('4_DLN', reg.dmv_id)
    set_digital_field(pdf, '4_SSN', 9, reg.ssn)
  end

  def self.set_part_5(pdf, reg, p)
    pdf.set('5_PHONE', reg.phone)
    pdf.set('5_EMAIL', reg.email)
  end

  def self.set_part_6(pdf, reg, p)
    pdf.set('6_MAIL_CHECK', 'Y')
  end

  def self.set_part_7(pdf, reg, p)
    pdf.set('7_STREET_ADDRESS', reg.vvr_address_1)
    pdf.set('7_APT', reg.vvr_address_2)
    pdf.set('7_CITY_TOWN_VILLAGE', reg.vvr_town)
    if reg.vvr_county_or_city.to_s =~ /county/i
      pdf.set('7_COUNTY', reg.vvr_county_or_city.to_s.gsub(/county/i, '').strip.upcase)
    end
    pdf.set('7_STATE', 'VA')
    set_digital_field(pdf, '7_ZIP', 9, [ reg.vvr_zip5, reg.vvr_zip4 ].rjoin(''))
  end

  def self.set_part_8(pdf, reg, p)
    lines = address_lines(reg)
    lines = lines.reject(&:blank?)

    5.times do |i|
      pdf.set("8_LINE_#{i + 1}", lines[i])
    end
  end

  def self.set_part_9(pdf, reg, p)
    new_voter = !reg.existing

    lines = []
    if new_voter
      lines << "Previous Virginia Residence Address: I have never voted."
    else
      lines << "Previous Virginia Residence Address: #{p.old_registration_address}"
    end

    if reg.vvr_uocava_residence_available == '1'
      lines << "Virginia Residence: still available"
    else
      lines << "Virginia Residence: not available since #{reg.vvr_uocava_residence_unavailable_since.strftime("%B %d, %Y")}"
    end

    if reg.outside_type == 'ActiveDutyMerchantMarineOrArmedForces' ||
       reg.outside_type == 'SpouseOrDependentActiveDutyMerchantMarineOrArmedForces'

      lines << "Service Branch #{reg.service_branch}; Service ID #{reg.service_id}; Rank #{reg.rank}"
    end

    6.times do |i|
      pdf.set("9_LINE_#{i + 1}", lines[i])
    end
  end

  def self.set_postage(pdf, reg, p)
    lines = [ reg.full_name, address_lines(reg) ].flatten
    5.times do |i|
      pdf.set("FROM_LINE_#{i + 1}", lines[i])
    end

    office_address = Office.where(locality: reg.vvr_county_or_city).first.try(:address)
    if office_address
      lines = [ "General Registrar", office_address.split("\n") ].flatten
      5.times do |i|
        pdf.set("TO_LINE_#{i + 1}", lines[i])
      end
    end
  end

  def self.address_lines(reg)
    @address_lines ||= if reg.mau_type == 'non-us'
      [ reg.mau_address,
        reg.mau_address_2,
        [ reg.mau_city, reg.mau_city_2 ].rjoin(' '),
        [ reg.mau_state,
          reg.mau_postal_code,
          reg.mau_country
        ].rjoin(', ')
      ]
    else
      [ reg.apo_address,
        reg.apo_address_2,
        reg.apo_city,
        [ reg.apo_state, reg.apo_zip5 ].rjoin(', ')
      ]
    end
  end

end
