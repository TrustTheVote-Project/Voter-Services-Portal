# Represents the details of registration record in human-digestable form.
class RegistrationDetailsPresenter

  extend Forwardable

  def_delegators :@registration, :full_name, :voting_address, :mailing_address, :email, :phone

  def initialize(reg)
    @registration = reg
  end

  # Formatted date of birth
  def dob
    @registration.dob.strftime('%B %d, %Y')
  end

  # Party affiliation or 'Not stated'
  def party_affiliation
    @registration.party_affiliation.blank? ? 'Not stated' : @registration.party_affiliation
  end

  # Absentee flag
  def absentee?
    true # TODO use real data
  end

  # Absentee status
  def absentee_status
    absentee? ? 'Resident Absentee Voter' : 'Active'
  end

  # Absentee status expiration date
  def absentee_status_expires_on
    # TODO use real data
    1.year.from_now.strftime('%B %d, %Y')
  end

end
