# Represents the details of registration record in human-digestable form.
class RegistrationDetailsPresenter

  extend Forwardable

  def_delegators :@registration, :full_name, :voting_address,
                 :mailing_address, :email, :phone, :absentee?, :uocava?

  def initialize(reg)
    @registration = reg
  end

  # Formatted date of birth
  def dob
    @registration.dob.strftime('%B %d, %Y')
  end

  def gender
    @registration.gender == 'f' ? 'Female' : 'Male'
  end

  def ssn
    "xxx-xx-#{@registration.ssn4}"
  end

  # Party affiliation or 'Not stated'
  def party
    p = @registration.party
    if p.blank?
      '(none)'
    elsif p == 'other'
      @registration.other_party
    else
      @registration.party
    end
  end

  def address_confidentiality?
    @registration.is_confidential_address == '1'
  end

  def status
    if uocava?
      "overseas"
    elsif absentee?
      "residential_absentee"
    else
      "residential_voter"
    end
  end

  def status_options
    st       = self.status
    statuses = [ "separator", "residential_voter", "residential_absentee", "overseas" ]
    [ st ] + (statuses - [ st ])
  end

  def registration_status
    if absentee?
      "#{uocava? ? 'Overseas' : 'Resident'} Absentee Voter"
    else
      "You are currently registered to vote in person"
    end
  end

  def registration_address
    @vvr ||= begin
      if !@registration.vvr_is_rural || @registration.vvr_is_rural == '0'
        if @registration.vvr_county_or_city.downcase.include?('county')
          city = @registration.vvr_town
        else
          city = @registration.vvr_county_or_city
        end

        zip = [ @registration.vvr_zip5, @registration.vvr_zip4 ].reject(&:blank?).join('-')
        [ [ [ @registration.vvr_street_number, @registration.vvr_apt ].reject(&:blank?).join(' / '), @registration.vvr_street_name, @registration.vvr_street_suffix ].reject(&:blank?).join(' '),
          city,
          [ 'VA', zip ].join(' ') ].reject(&:blank?).join(', ')
      else
        @registration.vvr_rural
      end
    end
  end

  def mailing_address
    if overseas?
      overseas_mailing_address
    else
      domestic_mailing_address
    end
  end

  def domestic_mailing_address
    if @registration.ma_is_same == 'yes'
      registration_address
    else
      us_address_no_rural(:ma)
    end
  end

  def overseas?
    @registration.uocava?
  end
end
