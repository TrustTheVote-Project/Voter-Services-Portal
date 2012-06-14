# Represents the details of registration record in human-digestable form.
class RegistrationDetailsPresenter

  extend Forwardable

  def_delegators :@registration, :full_name, :voting_address,
                 :mailing_address, :email, :phone, :absentee?, :uocava?

  def initialize(reg)
    @registration = reg
  end

  # Formatted date of birth
  def dob
    @registration.dob.strftime('%B %d, %Y')
  end

  def gender
    @registration.gender == 'f' ? 'Female' : 'Male'
  end

  def ssn
    "xxx-xx-#{@registration.ssn4}"
  end

  # Party affiliation or 'Not stated'
  def party_affiliation
    @registration.party_affiliation.blank? ? 'Not stated' : @registration.party_affiliation
  end

  def registration_status
    if absentee?
      "#{uocava? ? 'Overseas' : 'Resident'} Absentee Voter"
    else
      "You are currently registered to vote in person"
    end
  end

end
