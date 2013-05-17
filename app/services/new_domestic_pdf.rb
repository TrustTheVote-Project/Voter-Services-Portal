class NewDomesticPdf

  # Renders PDF and returns it as a string
  def self.render(reg)
    pdf_path = "#{Rails.root}/app/assets/pdf-templates/va-new-domestic.pdf"

    pdf = ActivePdftk::Form.new(pdf_path, path: AppConfig['pdftk_path'])

    setEligibility(pdf, reg)
    setIdentity(pdf, reg)
    setHomeAddress(pdf, reg)
    setMailingAddress(pdf, reg)
    setVoterRightsStatus(pdf, reg)
    setRegistrationStatement(pdf, reg)
    setOptionalQuestions(pdf, reg)
    setPreviousRegistrationInfo(pdf, reg)

    # Flatten to render and remove active form fields
    pdf.save(nil, options: { flatten: true })
  end

  private

  def self.setEligibility(pdf, reg)
    pdf.set('CITIZEN', reg.citizen == '1' ? 'Y' : 'N')
  end

  def self.setIdentity(pdf, reg)
    pdf.set('LOCALITY', reg.vvr_county_or_city.to_s.upcase)
    pdf.set('LAST_NAME', reg.last_name.to_s.upcase)
    pdf.set('FIRST_NAME', reg.first_name.to_s.upcase)
    pdf.set('MIDDLE_NAME', reg.middle_name.to_s.upcase)
    pdf.set('SUFFIX', reg.suffix.to_s.upcase)
    pdf.set('EMAIL', reg.email)
    pdf.set('GENDER', reg.gender =~ /F/ ? 'F' : 'M')
    setDigitalField(pdf, 'SSN',    9, reg.ssn)
    setDigitalField(pdf, 'DOB',    8, reg.dob.strftime("%m%d%Y")) unless reg.dob.blank?
    setDigitalField(pdf, 'PHONE', 10, reg.phone.gsub(/[^0-9]/, '')) unless reg.phone.blank?
  end

  def self.setHomeAddress(pdf, reg)
    if reg.vvr_is_rural != '1'
      pdf.set('HOME_CITY', home_city(reg))
      setDigitalField(pdf, 'HOME_ZIP', 5, reg.vvr_zip5)
      pdf.set('HOME_ADDRESS', home_address(reg))
    else
      pdf.set('HOME_ADDRESS', reg.vvr_rural.to_s.upcase)
    end
  end

  def self.setMailingAddress(pdf, reg)
    if reg.ma_is_different == '1'
      line1 = reg.ma_address
      line2 = [
        reg.ma_address_2,
        reg.ma_city,
        [ reg.ma_state,
          [ reg.ma_zip5, reg.ma_zip4 ].rjoin('-')
        ].rjoin(' ')
      ].rjoin(', ')
    else
      line1 = home_address(reg)
      line2 = "#{home_city(reg)}, VA #{[ reg.vvr_zip5, reg.vvr_zip4 ].rjoin('-')}"
    end

    pdf.set('MAILING_ADDRESS_1', line1.to_s.upcase)
    pdf.set('MAILING_ADDRESS_2', line2.to_s.upcase)
  end

  def self.setVoterRightsStatus(pdf, reg)
    if reg.rights_revoked == '1'
      pdf.set('RIGHTS', reg.rights_revoked_reason == 'felony' ? 'F' : 'M')
      pdf.set('RIGHTS_RESTORED', reg.rights_restored == '1' ? 'Y' : 'N')
      setDigitalField(pdf, 'RIGHTS_RESTORED', 8, reg.rights_restored_on.strftime('%m%d%Y')) unless reg.rights_restored_on.blank?
    else
      pdf.set('RIGHTS', 'N')
      pdf.set('RIGHTS_RESTORED', '')
    end
  end

  def self.setRegistrationStatement(pdf, reg)
    setDigitalField(pdf, 'STATEMENT', 8, Time.now.strftime('%m%d%Y'))
  end

  def self.setOptionalQuestions(pdf, reg)
    if reg.is_confidential_address == '1'
      setDigitalField(pdf, 'CODE', 3, reg.ca_type.to_s.upcase)
    end

    pdf.set('NEED_ASSISTANT', reg.need_assistance == '1' ? 'Y' : 'N')
    pdf.set('BE_OFFICIAL', reg.be_official == '1' ? 'Y' : 'N')
  end

  def self.setPreviousRegistrationInfo(pdf, reg)
    if reg.has_existing_reg == '1'
      pdf.set('PREV_REG', 'Y')

      if reg.er_is_rural == '1'
        pdf.set('PREV_REG_ADDRESS', reg.er_rural.to_s.upcase)
      else
        pdf.set('PREV_REG_ADDRESS', [ [ reg.er_street_number, reg.er_street_name ].rjoin(' '), reg.er_apt ].rjoin(', ').to_s.upcase)
        pdf.set('PREV_REG_CITY', reg.er_city.to_s.upcase)
        pdf.set('PREV_REG_STATE', reg.er_state.to_s.upcase)
        pdf.set('FULLNAME', [ reg.first_name, reg.middle_name, reg.last_name, reg.suffix ].rjoin(' ').to_s.upcase)
        setDigitalField(pdf, 'PREV_REG_ZIP', 5, reg.er_zip5)
        setDigitalField(pdf, 'PREV_REG_SSN', 9, reg.ssn) unless reg.ssn.blank?
        setDigitalField(pdf, 'PREV_REG_DOB', 8, reg.dob.strftime('%m%d%Y')) unless reg.dob.blank?
      end
    else
      pdf.set('PREV_REG', 'N')
    end
  end

  def self.setDigitalField(pdf, key, cells, text)
    return if text.blank?
    cells.times do |i|
      pdf.set("#{key}_#{i + 1}", text[i])
    end
  end

  def self.home_address(reg)
    [ [ reg.vvr_street_number,
        reg.vvr_street_name,
        reg.vvr_street_suffix,
        reg.vvr_street_type
      ].rjoin(' '),
      reg.vvr_apt
    ].rjoin(', ').upcase
  end

  def self.home_city(reg)
    city = reg.vvr_county_or_city
    if city.blank? || city.to_s.downcase.include?('county')
      city = reg.vvr_town
    end
    city.to_s.upcase
  end

end
