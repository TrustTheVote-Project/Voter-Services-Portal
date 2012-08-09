# Represents the details of registration record in human-digestable form.
class RegistrationDetailsPresenter

  extend Forwardable

  def_delegators :@registration, :full_name, :voting_address,
                 :absentee?, :uocava?

  def initialize(reg)
    @registration = reg
    @vvr = {}
  end

  def optional_email
    @registration.email
  end

  def email
    optional(@registration.email)
  end

  def optional_phone
    @registration.phone
  end

  def phone
    optional(@registration.phone)
  end

  # Formatted date of birth
  def dob
    @registration.dob.try(:strftime, '%B %d, %Y')
  end

  def gender
    @registration.gender == 'f' ? 'Female' : 'Male'
  end

  def ssn
    @registration.ssn4.blank? ? nil : "xxx-xx-#{@registration.ssn4}"
  end

  # Party affiliation or 'Not stated'
  def party
    p = @registration.party
    if p.blank?
      'none'
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
    if @registration.current_residence == 'outside'
      "overseas"
    else
      "residential_voter"
    end
  end

  def status_options
    st       = self.status
    statuses = [ "separator", "residential_voter", "overseas" ]

    [ st ] + (statuses - [ st ])
  end

  def registration_address(d = :data)
    @vvr[d] ||= begin
      data = @registration.send(d)

      if !data[:vvr_is_rural] || data[:vvr_is_rural] != '1'
        if data[:vvr_county_or_city].to_s.downcase.include?('county')
          city = data[:vvr_town]
        else
          city = data[:vvr_county_or_city]
        end

        zip = [ data[:vvr_zip5], data[:vvr_zip4] ].reject(&:blank?).join('-')
        [ [ [ data[:vvr_street_number], data[:vvr_apt] ].reject(&:blank?).join(' / '),
            data[:vvr_street_name], data[:vvr_street_suffix] ].reject(&:blank?).join(' '),
          city,
          [ 'VA', zip ].join(' ') ].reject(&:blank?).join(', ')
      else
        data[:vvr_rural].to_s.gsub("\n", "<br/>").html_safe
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

  def update_mailing_address(d = :data)
    if d == :data ? @registration.currently_overseas? : overseas?(d)
      overseas_mailing_address(d)
    else
      domestic_mailing_address(d)
    end
  end

  def domestic_mailing_address(d = :data)
    if @registration.send(d)[:ma_is_same] == '1'
      registration_address(d)
    else
      us_address_no_rural(:ma, d)
    end
  end

  def us_address_no_rural(prefix, d = :data)
    data = @registration.send(d)
    [ data[:"#{prefix}_address"],
      data[:"#{prefix}_address_2"],
      data[:"#{prefix}_city"],
      data[:"#{prefix}_state"],
      [ data[:"#{prefix}_zip5"], data[:"#{prefix}_zip4"] ].reject(&:blank?).join('-')
    ].reject(&:blank?).join(', ')
  end

  def overseas_mailing_address(d = :data)
    data = @registration.send(d)
    if data[:mau_type] == 'non-us'
      abroad_address :mau, d
    else
      [ data[:apo_address],
        data[:apo_1],
        data[:apo_2],
        data[:apo_zip5] ].reject(&:blank?).join(', ')
    end
  end

  def abroad_address(prefix, d = :data)
    data = @registration.send(d)
    [ [ data[:"#{prefix}_address"], data[:"#{prefix}_address_2"] ].reject(&:blank?).join(' '),
      [ data[:"#{prefix}_city"], data[:"#{prefix}_city_2"] ].reject(&:blank?).join(' '),
      data[:"#{prefix}_state"],
      data[:"#{prefix}_postal_code"],
      data[:"#{prefix}_country"]
    ].reject(&:blank?).join(', ')
  end

  def overseas?(d = :data)
    @registration.send(d)[:residence] == 'outside'
  end

  protected

  def optional(v)
    v.blank? ? '&nbsp;'.html_safe : v
  end

end
