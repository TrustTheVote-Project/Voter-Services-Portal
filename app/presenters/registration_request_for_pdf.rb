class RegistrationRequestForPdf

  def initialize(req)
    @req = req
  end

  # Rights

  def felony_rights_revoked?
    @req.convicted != 'false'
  end

  def felony_state
    @req.convicted_in_state
  end

  def felony_restored_on
    @req.convicted_rights_restored_on.try(:strftime, "%m/%d/%Y")
  end

  def mental_rights_revoked?
    @req.mental != 'false'
  end

  def mental_restored_on
    @req.mental_rights_restored_on.try(:strftime, "%m/%d/%Y")
  end

  # Identity

  def name
    [ @req.title,
      @req.first_name,
      @req.middle_name,
      @req.last_name,
      @req.suffix ].reject(&:blank?).join(' ')
  end

  def email
    @req.email
  end

  def ssn
    n = @req.ssn
    return '' if n.blank?

    "#{n[0, 3]}-#{n[3, 2]}-#{n[5, 4]}"
  end

  def dob
    @req.dob.try(:strftime, '%m/%d/%Y')
  end

  def phone
    @req.phone
  end

  def gender
    @req.gender
  end

  def party_preference
    "none"
  end

  # Addresses

  def registration_address
    "RR 2 Box 23, San Francisco, CA 94110"
  end

  def mailing_address
    "P.O. Box 876, Fredericksberg, VA 22412"
  end

  def previous_registration?
    true
  end

  def previous_registration_address
    "456 Junipero Serra St., San Francisco, CA 94110"
  end

  def address_confidentiality?
    true
  end

end
