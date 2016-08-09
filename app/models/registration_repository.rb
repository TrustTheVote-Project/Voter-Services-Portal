# Repository of registrations used by active sessions
# with the portal.
#
# We store records here while the user is active to maintain
# the state and remove them once they leave the portal.
class RegistrationRepository
  extend ConfigHelper
  
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
    if query.respond_to?(:dob)
      session[:s_dob]         = query.dob.try(:strftime, "%Y-%m-%d")
      session[:s_ssn4]        = query.ssn4
      session[:s_locality]    = query.locality
      session[:s_voter_id]    = query.voter_id
      session[:s_lookup_type] = query.lookup_type
    else
      if lookup_service_config['street_name']
        session[:s_street_name]   = query.street_name
      end
      if lookup_service_config['street_type']
        session[:s_street_type]   = query.street_type
      end
      if lookup_service_config['street_number']
        session[:s_street_number]   = query.street_number
      end
      if lookup_service_config['vvr_address_1']
        session[:s_vvr_address_1]   = query.vvr_address_1
      end
      if lookup_service_config['vvr_town']
        session[:s_vvr_town]   = query.vvr_town
      end
      if lookup_service_config['vvr_zip5']
        session[:s_vvr_zip5]   = query.vvr_zip5
      end
      if lookup_service_config['date_of_birth']
        session[:s_dob]         = query.date_of_birth.try(:strftime, "%Y-%m-%d")
      end
      #session[:s_id_document_number]    = query.id_document_number
    end
  end

  # restore search query to render search screen again
  def self.restore_search_query_options(session)
    result = {}
    date_fields = [:s_dob]

    rules = [
      [:s_first_name, :first_name],
      [:s_last_name,  :last_name],
      [:s_dob, :date_of_birth],
      # [:s_dob, :dob],
      [:s_ssn4, :ssn4],
      [:s_locality, :locality],
      [:s_voter_id, :voter_id],
      [:s_lookup_type, :lookup_type],
      [:s_street_name, :street_name],
      [:s_street_type, :street_type],
      [:s_street_number, :street_number],
      [:s_vvr_address_1, :vvr_address_1],
      [:s_vvr_town, :vvr_town],
      [:s_vvr_zip5, :vvr_zip5]
    ]

    rules.each do |from, to|
      value = session.delete(from)
      if value && date_fields.include?(from)
        result[to] = Date.parse(value) rescue nil
      elsif value
        result[to] = value
      end
    end

    result
  end

  # Gets stored search query params for registration
  def self.pop_search_query(session)
    dob = session.delete(:s_dob)
    { lookup_type:  session.delete(:s_lookup_type),
      first_name:   session.delete(:s_first_name),
      last_name:    session.delete(:s_last_name),
      dob:          dob.blank? ? nil : Date.parse(dob),
      ssn4:         session.delete(:s_ssn4),
      locality:     session.delete(:s_locality),
      voter_id:     session.delete(:s_voter_id),
      ca_address_street_number:  session.delete(:s_street_number),
      ca_address_street_name:  session.delete(:s_street_name),
      ca_address_street_type:  session.delete(:s_street_type),
      vvr_address_1: session.delete(:s_vvr_address_1),
      vvr_town: session.delete(:s_vvr_town),
      vvr_zip5: session.delete(:s_vvr_zip5),
    }

  end

  # Stores DOB and SSN4 used in lookup in session
  def self.store_lookup_data(session, query)
    session[:l_dob]   = query.dob.try(:strftime, "%Y-%m-%d")
    session[:l_ssn4]  = query.ssn4
  end

  # Returns the stored lookup SSN4
  def self.get_lookup_ssn4(session)
    session[:l_ssn4]
  end

  # Pops lookup DOB and SSN4 from session
  def self.pop_lookup_data(session)
    dob = session.delete(:l_dob)

    { dob:  dob.blank? ? nil : Date.parse(dob),
      ssn4: session.delete(:l_ssn4) }
  end

end
