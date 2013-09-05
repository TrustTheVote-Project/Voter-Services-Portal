class BallotInfoPresenter

  def initialize(info)
    @i = info
  end

  def election_name
    "#{@i[:election][:name]} #{I18n.t('ballot_info.election')}"
  end

  def election_date
    @i[:election][:date].strftime("%B %d, %Y")
  end

  def locality
    @i[:locality].titleize
  end

  def precinct
    @i[:precinct]
  end

  def contests
    @i[:contests]
  end

end
