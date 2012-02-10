class RegistrationRequest < ActiveRecord::Base

  include Concern::SerializedAttrs

  SERVICE_BRANCHES = [ 'Navy', 'Air Force', 'Marines', 'Merchant Marine' ]

  # Eligibility
  serialized_attr :citizen, :old_enough
  serialized_attr :residence, :outside_type
  serialized_attr :outside_active_service_branch, :outside_active_service_id, :outside_active_rank
  serialized_attr :outside_spouse_service_branch, :outside_spouse_service_id, :outside_spouse_rank
  serialized_attr :convicted, :convicted_restored, :convicted_in_state, :convicted_rights_restored_on
  serialized_attr :mental,    :mental_restored,    :mental_rights_restored_on

  # Identity
  serialized_attr :title, :first_name, :middle_name, :last_name, :suffix
  serialized_attr :dob, :gender, :ssn, :dln, :no_ssn, :no_dln
  serialized_attr :phone, :email

end
