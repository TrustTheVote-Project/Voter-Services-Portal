class RegistrationRequestForPdf

  def initialize(req)
    @req = req
  end

  # Rights

  def voting_rights_revoked?
    true
  end

  def state_where_convicted
    "CA"
  end

  def date_when_restored
    "02/24/2011"
  end

  # Identity

  def name
    "Mr. John Quincy Public"
  end

  def email
    "john@email.com"
  end

  def ssn
    "123-12-1234"
  end

  def dob
    "05/14/1975"
  end

  def phone
    "(540) 555-4567"
  end

  def gender
    "Male"
  end

  def party_preference
    "Democrat"
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
