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

  def address_line_1
    [ @r.ma_street_number, @r.ma_street_name, @r.ma_street_type ].rjoin(', ')
  end

  def address_line_2
    "#{@r.ma_city}, #{@r.ma_state} #{[ @r.ma_zip5, @r.ma_zip4 ].rjoin('-')}"
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
