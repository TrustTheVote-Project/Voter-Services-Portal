class VoterCard

  def initialize(registration)
    @r = registration
  end

  def id
    @r.voter_id
  end

  def date_issued
    # TODO implement
    Time.now.strftime("%m/%d/%Y")
  end

  def name
    @r.full_name
  end

  def registration_line_1
    if !@r.vvr_is_rural || @r.vvr_is_rural != '1'
      [ [ @r.vvr_street_number, @r.vvr_apt ].reject(&:blank?).join(' / '),
        @r.vvr_street_name, @r.vvr_street_suffix ].reject(&:blank?).join(' ')
    else
      @r.vvr_rural
    end
  end

  def registration_line_2
    if !@r.vvr_is_rural || @r.vvr_is_rural != '1'
      if @r.vvr_county_or_city.to_s.downcase.include?('county')
        city = @r.vvr_town
      else
        city = @r.vvr_county_or_city
      end

      zip = [ @r.vvr_zip5, @r.vvr_zip4 ].reject(&:blank?).join('-')

      [ city, [ 'VA', zip ].join(' ') ].reject(&:blank?).join(', ')
    end
  end

  def mailing_line_1
    # TODO ???
    "PO BOX 37574"
  end

  def mailing_line_2
    # TODO ???
    "RICHMOND, VA 23234-7574"
  end

  def language
    # TODO implement
  end

  def voting_location_line_1
    # TODO implement
    "FIRST BAPTIST CHURCH CENTRALIA"
  end

  def voting_location_line_2
    # TODO implement
    "2920 KINGSDALE RD"
  end

  def locality
    @r.poll_locality
  end

  def precinct
    @r.poll_precinct
  end

  def districts
    # TODO ???
    [ ].join(" &nbsp ")
  end

  def local
    @r.poll_district
  end

  def voter_registration_office
    Office.where(locality: locality).first.try(:address)
  end

end
