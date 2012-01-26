class RegistrationRequest < ActiveRecord::Base

  belongs_to :virginia_voting_address, class_name: 'Address'
  belongs_to :mailing_address, class_name: 'Address'
  belongs_to :foreign_state_address, class_name: 'Address'
  belongs_to :non_us_residence_address, class_name: 'Address'

  attr_accessible :title, :first_name, :middle_name, :last_name, :suffix_name_text
  attr_accessible :dln_or_ssn, :dob, :citizen, :old_enough, :was_convicted, :conviction_state
  attr_accessible :rights_restored_on, :residence, :gender, :identify_by
  attr_accessible :phone, :email, :authorized_cancelation

end
