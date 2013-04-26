class LookupService

  # stub registration lookup
  def self.registration(record)
    if record[:dmv_id].size == 12
      { registered: true }
    elsif record[:dmv_id].size == 9
      { registered: false, dmv_match: true }
    else
      { registered: false, dmv_match: false }
    end
  end

end
