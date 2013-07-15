class Office < ActiveRecord::Base

  # Returns all supported localities
  def self.localities
    Office.select(:locality).order('locality').map(&:locality)
  end

  def address
    [ self.addressline,
      [ self.city, self.state, self.zip ].rjoin(", "),
      self.phone ].rjoin("\n")
  end

end
