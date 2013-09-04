class BallotInfoPresenter

  def initialize(info)
    @i = info
  end

  def election_name
    @i[:election][:name]
  end

  def election_date
    @i[:election][:date].strftime("%B %d, %Y")
  end

  def locality
    @i[:locality].capitalize
  end

  def precinct
    @i[:precinct]
  end

end
