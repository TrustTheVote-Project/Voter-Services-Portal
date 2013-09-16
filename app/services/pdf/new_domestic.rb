class Pdf::NewDomestic < Pdf::Form

  # Renders PDF and returns it as a string
  def self.render(reg)
    render_pdf("Portal_PDF_sbe_voter_app.pdf") do |pdf|
      setMailingInstructions(pdf, reg)
      setEligibility(pdf, reg)
      setIdentity(pdf, reg)
      setAddresses(pdf, reg)
      setVoterRightsStatus(pdf, reg)
      setRegistrationStatement(pdf, reg)
      setOptionalQuestions(pdf, reg)
      setPreviousRegistrationInfo(pdf, reg)
    end
  end

  private

  def self.setMailingInstructions(pdf, reg)
    address = Office.where(locality: reg.vvr_county_or_city).first.try(:address)
    pdf.set("INSTRUCTIONS_ADDRESS", "General Registrar\n#{address}".gsub("\n", ", "))
  end

  def self.setCheck(pdf, key, v, values = nil)
    pdf.set("#{key}_#{v ? "Y" : "N"}", "Y")
  end

  def self.setEligibility(pdf, reg)
    setCheck(pdf, 'CITIZEN', reg.citizen)
    setCheck(pdf, 'AGE', reg.old_enough)
  end

  def self.setIdentity(pdf, reg)
    setDigitalField(pdf, 'SSN', 9, reg.ssn)
    pdf.set("GENDER_#{reg.gender =~ /F/ ? "F" : "M"}", "Y")
    setDateField(pdf, 'DOB', reg.dob)
    setDigitalField(pdf, 'PHONE', 10, reg.phone.gsub(/[^0-9]/, '')) unless reg.phone.blank?
    pdf.set("LAST_NAME", reg.last_name)
    pdf.set('FIRST_NAME', reg.first_name)

    if reg.middle_name.blank?
      pdf.set('MIDDLE_NAME_NONE', 'Y')
    else
      pdf.set('MIDDLE_NAME', reg.middle_name)
    end

    if reg.suffix.blank?
      pdf.set('SUFFIX_NONE', 'Y')
    else
      pdf.set('SUFFIX', reg.suffix)
    end
  end

  def self.setAddresses(pdf, reg)
    if reg.vvr_is_rural == '1'
      pdf.set('HOME_RURAL', reg.vvr_address_1)
    else
      pdf.set('HOME_ADDRESS', reg.vvr_address_1)
      pdf.set('HOME_APT', reg.vvr_address_2) if reg.vvr_address_2.present?
    end

    pdf.set('HOME_CITY', reg.vvr_town)
    pdf.set('HOME_ZIP', [ reg.vvr_zip5, reg.vvr_zip4 ].rjoin('-'))
    pdf.set('EMAIL', reg.email)

    pdf.set('CITY_OR_COUNTY', reg.vvr_county_or_city.to_s.gsub(/\s*(COUNTY|CITY)/i, ''))
    setCheck(pdf, 'IS_CITY', reg.vvr_county_or_city =~ /CITY/i)

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
        setCheck(pdf, 'CONVICTED', true)
        pdf.set('CONVICTED_STATE', reg.rights_felony_restored_in)
        setCheck(pdf, 'CONVICTED_RESTORED', reg.rights_felony_restored == '1')
        setDateField(pdf, 'CONVICTED_RESTORED_ON', reg.rights_felony_restored_on)
      else
        setCheck(pdf, 'CONVICTED', false)
      end

      if reg.rights_mental == '1'
        setCheck(pdf, 'MENTAL', true)
        setCheck(pdf, 'MENTAL_RESTORED', reg.rights_mental_restored == '1')
        setDateField(pdf, 'MENTAL_RESTORED_ON', reg.rights_mental_restored_on)
      else
        setCheck(pdf, 'MENTAL', false)
      end
    else
      pdf.set('CONVICTED_N', 'Y')
      pdf.set('MENTAL_N', 'Y')
    end
  end

  def self.setRegistrationStatement(pdf, reg)
    if AppConfig['pdf']['fill_sign_date']
      setDateField(pdf, 'STATEMENT', Time.now)
    end

    details = [
      reg.as_full_name,
      reg.as_full_address
    ].rjoin(', ')
    pdf.set('ASSISTANT_DETAILS', details) unless details.blank?
  end

  def self.setOptionalQuestions(pdf, reg)
    if reg.is_confidential_address == '1'
      setDigitalField(pdf, 'PROTECTED_VOTER_CODE', 3, reg.ca_type.to_s.upcase)
    end

    pdf.set('NEED_ASSISTANT', 'Y') if reg.need_assistance == '1'
    pdf.set('INTEREST_IN_ELECTION_DAY_OFFICIAL_CHECK', 'Y') if reg.be_official == '1'
  end

  def self.setPreviousRegistrationInfo(pdf, reg)
    if reg.pr_status == '1'
      setCheck(pdf, 'PREV_REG', true)

      pdf.set('PREV_REG_FULL_NAME', [ reg.pr_first_name, reg.pr_middle_name, reg.pr_last_name, reg.pr_suffix ].rjoin(' '))
      pdf.set('PREV_REG_ADDRESS', [ reg.pr_address, reg.pr_address_2 ].rjoin(', '))
      pdf.set('PREV_REG_CITY', reg.pr_city)
      pdf.set('PREV_REG_STATE', reg.pr_state)
      pdf.set('PREV_REG_ZIP', [ reg.pr_zip5, reg.pr_zip4 ].rjoin('-'))
      pdf.set('PREV_REG_COUNTY', reg.pr_county_or_city)

      setDigitalField(pdf, 'PREV_REG_SSN', 9, reg.ssn)
      setDateField(pdf, 'PREV_REG_DOB', reg.dob)
    else
      pdf.set('PREV_REG_N', 'Y')
    end
  end

end
