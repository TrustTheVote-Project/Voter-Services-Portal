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
    if @r.currently_overseas?
      if @r.mau_type == 'apo'
        [ @r.apo_address, @r.apo_address_2 ].rjoin(', ')
      else
        [ @r.mau_address, @r.mau_address_2 ].rjoin(', ')
      end
    else
      [ @r.ma_address, @r.ma_address_2 ].rjoin(', ')
    end
  end

  def address_line_2
    if @r.currently_overseas?
      if @r.mau_type == 'apo'
        [ @r.apo_1, @r.apo_2, @r.apo_zip5 ].rjoin(', ')
      else
        [ @r.mau_city, @r.mau_city_2, @r.mau_state, @r.mau_postal_code, @r.mau_country ].rjoin(", ")
      end
    else
      "#{@r.ma_city}, #{@r.ma_state} #{[ @r.ma_zip5, @r.ma_zip4 ].rjoin('-')}"
    end
  end

  def language
    @r.lang_preference || "Eng"
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
