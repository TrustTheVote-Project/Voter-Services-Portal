# Repository of registrations used by active sessions
# with the portal.
#
# We store records here while the user is active to maintain
# the state and remove them once they leave the portal.
class RegistrationRepository

  # Find a registration for the current session
  def self.get_registration(session)
    rid = session[:registration_id]
    rid ? Registration.find_by_id(rid) : nil
  end

  # Store a registration for the given session
  def self.store_registration(session, registration)
    registration.save unless registration.persisted?
    session[:registration_id] = registration.id
  end

  # Removes registration data for the given session
  def self.remove_registration(session)
    rid = session[:registration_id]
    Registration.delete_all(id: rid) if rid
    session.delete(:registration_id)
  end

end
