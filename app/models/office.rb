class Office < ActiveRecord::Base

  # Returns all supported localities
  def self.localities
    Office.select(:locality).order('locality').map(&:locality)
  end

end
