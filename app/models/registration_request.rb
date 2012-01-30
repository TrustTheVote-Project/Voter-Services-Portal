class RegistrationRequest < ActiveRecord::Base

  VOTING_RIGHTS = {
    restored:   'restored',
    unrevoked:  'unrevoked'
  }

  belongs_to :virginia_voting_address, class_name: 'Address'
  belongs_to :mailing_address, class_name: 'Address'
  belongs_to :foreign_state_address, class_name: 'Address'
  belongs_to :non_us_residence_address, class_name: 'Address'

  attr_accessible :title, :first_name, :middle_name, :last_name, :suffix_name_text
  attr_accessible :ssn, :dob, :citizen, :old_enough, :dln_or_stateid
  attr_accessible :voting_rights, :conviction_state, :rights_restored_on
  attr_accessible :residence, :gender, :identify_by
  attr_accessible :phone, :email, :authorized_cancelation

  accepts_nested_attributes_for :virginia_voting_address

end
