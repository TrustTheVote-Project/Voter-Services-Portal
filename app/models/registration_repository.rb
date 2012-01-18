# Repository of registrations used by active sessions
# with the portal.
#
# We store records here while the user is active to maintain
# the state and remove them once they leave the portal.
class RegistrationRepository

  # Find a registration for the current session
  def self.get_registration(session_key)
  end

  # Store a registration for the given session
  def self.store_registration(session_key, registration)
  end

  # Removes registration data for the given session
  def self.remove_registration(session_key)
  end

end
