class Pdf::NewDomestic

  # Renders PDF and returns it as a string
  def self.render(reg)
    pdf_path = "#{Rails.root}/app/assets/pdf-templates/Portal_PDF_sbe_voter_app.pdf"

    pdf = ActivePdftk::Form.new(pdf_path, path: AppConfig['pdftk_path'])

    setMailingInstructions(pdf, reg)
    setEligibility(pdf, reg)
    setIdentity(pdf, reg)
    setAddresses(pdf, reg)
    setVoterRightsStatus(pdf, reg)
    setRegistrationStatement(pdf, reg)
    setOptionalQuestions(pdf, reg)
    setPreviousRegistrationInfo(pdf, reg)

    # Flatten to render and remove active form fields
    pdf.save(nil, options: { flatten: true })
  end

  private

  def self.setMailingInstructions(pdf, reg)
    address = Office.where(locality: reg.vvr_county_or_city).first.try(:address)
    pdf.set("Addresspage1", "General Registrar\n#{address}".gsub("\n", ", "))
  end

  def self.setEligibility(pdf, reg)
    Rails.logger.info "Setting eli"
    pdf.set('CITIZEN', reg.citizen == '1' ? '1' : '0')
    pdf.set('AGE',     reg.old_enough == '1' ? '1' : '0')
  end

  def self.setIdentity(pdf, reg)
    setDigitalField(pdf, 'SSN',    9, reg.ssn)
    pdf.set('GENDER', reg.gender =~ /F/ ? '1' : '0')
    setDigitalField(pdf, 'DOB',    8, reg.dob.strftime("%m%d%Y")) unless reg.dob.blank?
    setDigitalField(pdf, 'PHONE', 10, reg.phone.gsub(/[^0-9]/, '')) unless reg.phone.blank?
    pdf.set("LAST_NAME", reg.last_name.to_s.upcase)
    pdf.set('FIRST_NAME', reg.first_name.to_s.upcase)

    if reg.middle_name.blank?
      pdf.set('MIDDLE_NAME_NONE', 'Y')
    else
      pdf.set('MIDDLE_NAME', reg.middle_name.to_s.upcase)
    end

    if reg.suffix.blank?
      pdf.set('SUFFIX_NONE', 'Y')
    else
      pdf.set('SUFFIX', reg.suffix.to_s.upcase)
    end
  end

  def self.setAddresses(pdf, reg)
    pdf.set('HOME_ADDRESS', reg.vvr_address_1)

    if reg.vvr_address_2.present?
      if reg.vvr_is_rural == '1'
        pdf.set('HOME_RURAL', reg.vvr_address_2)
      else
        pdf.set('HOME_APT', reg.vvr_address_2)
      end
    end

    pdf.set('HOME_CITY', home_city(reg))
    setDigitalField(pdf, 'HOME_ZIP', 5, reg.vvr_zip5)
    pdf.set('EMAIL', reg.email)

    pdf.set('CITY_OR_COUNTY', reg.vvr_county_or_city.to_s.upcase.gsub(/\s*(COUNTY|CITY)/, ''))
    # yes, 0 for city, 1 for county. weird
    pdf.set('IS_CITY', reg.vvr_county_or_city =~ /CITY/i ? "0" : "1")

    if reg.ma_is_different == '1'
      pdf.set('MAILING_ADDRESS', [
        reg.ma_address,
        reg.ma_address_2,
        reg.ma_city,
        [ reg.ma_state,
          [ reg.ma_zip5, reg.ma_zip4 ].rjoin('-')
        ].rjoin(' ')
      ].rjoin(', '))
    end
  end

  def self.setVoterRightsStatus(pdf, reg)
    if reg.rights_revoked == '1'
      if reg.rights_felony == '1'
        pdf.set('CONVICTED', '0') # yes
        pdf.set('CONVICTED_STATE', reg.rights_felony_restored_in.to_s.upcase)
        pdf.set('CONVICTED_RESTORED', reg.rights_felony_restored == '1' ? '0' : '1')
        setDigitalField(pdf, 'CONVICTED_RESTORED_ON', 8, reg.rights_felony_restored_on.strftime("%m%d%Y")) unless reg.rights_felony_restored_on.blank?
      end

      if reg.rights_mental == '1'
        pdf.set('MENTAL', '1') # yes
        pdf.set('MENTAL_RESTORED', reg.rights_mental_restored == '1' ? '0' : '1')
        setDigitalField(pdf, 'MENTAL_RESTORED_ON', 8, reg.rights_mental_restored_on.strftime("%m%d%Y")) unless reg.rights_mental_restored_on.blank?
      end
    else
      pdf.set('CONVICTED', '1') # no
      pdf.set('MENTAL', '1') # no
    end
  end

  def self.setRegistrationStatement(pdf, reg)
    setDigitalField(pdf, 'STATEMENT', 8, Time.now.strftime('%m%d%Y'))
  end

  def self.setOptionalQuestions(pdf, reg)
    if reg.is_confidential_address == '1'
      setDigitalField(pdf, 'PROTECTED_VOTER_CODE', 3, reg.ca_type.to_s.upcase)
    end

    pdf.set('NEED_ASSISTANT', reg.need_assistance == '1' ? 'Y' : 'N')
    pdf.set('INTEREST_IN_ELECTION_DAY_OFFICIAL_CHECK', reg.be_official == '1' ? 'Yes' : 'No')
  end

  def self.setPreviousRegistrationInfo(pdf, reg)
    if reg.pr_status == '1'
      pdf.set('PREV_REG', '1')

      pdf.set('PREV_REG_FULL_NAME', [ reg.pr_first_name, reg.pr_middle_name, reg.pr_last_name, reg.pr_suffix ].rjoin(' ').to_s.upcase)
      pdf.set('PREV_REG_ADDRESS', [ reg.pr_address, reg.pr_address_2 ].rjoin(', ').to_s.upcase)
      pdf.set('PREV_REG_CITY', reg.pr_city.to_s.upcase)
      pdf.set('PREV_REG_STATE', reg.pr_state.to_s.upcase)
      pdf.set('PREV_REG_ZIP', reg.pr_zip5)
      pdf.set('PREV_REG_COUNTRY', 'United States')

      setDigitalField(pdf, 'PREV_REG_SSN', 9, reg.ssn) unless reg.ssn.blank?
      setDigitalField(pdf, 'PREV_REG_DOB', 8, reg.dob.strftime('%m%d%Y')) unless reg.dob.blank?
    else
      pdf.set('PREV_REG', '0')
    end
  end

  def self.setDigitalField(pdf, key, cells, text)
    return if text.blank?
    cells.times do |i|
      pdf.set("#{key}_#{i + 1}", text[i])
    end
  end

  def self.home_city(reg)
    city = reg.vvr_county_or_city
    if city.blank? || city.to_s.downcase.include?('county')
      city = reg.vvr_town
    end
    city.to_s.upcase
  end

end
