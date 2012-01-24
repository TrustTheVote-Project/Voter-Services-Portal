# Removes stale session data
class SessionCleaner

  def self.perform
    Registration.stale.destroy_all
  end

end
