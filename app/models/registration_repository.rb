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

  # Stores search query params for registration
  def self.store_search_query(session, query)
    session[:s_first_name]  = query.first_name
    session[:s_last_name]   = query.last_name
    session[:s_dob]         = query.dob.try(:strftime, "%Y-%m-%d")
    session[:s_ssn4]        = query.ssn4
    session[:s_locality]    = query.locality
    session[:s_voter_id]    = query.voter_id
    session[:s_lookup_type] = query.lookup_type
  end

  # Gets stored search query params
  def self.pop_search_query(session)
    dob = session.delete(:s_dob)
    { lookup_type:  session.delete(:s_lookup_type),
      first_name:   session.delete(:s_first_name),
      last_name:    session.delete(:s_last_name),
      dob:          dob.blank? ? nil : Date.parse(dob),
      ssn4:         session.delete(:s_ssn4),
      locality:     session.delete(:s_locality),
      voter_id:     session.delete(:s_voter_id) }
  end

end
