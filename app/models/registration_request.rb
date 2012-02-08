class RegistrationRequest < ActiveRecord::Base

  include Concern::SerializedAttrs

  # Eligibility
  serialized_attr :citizen, :old_enough
  serialized_attr :residence, :outside_type, :outside_spouse_active_duty_details, :outside_active_duty_details
  serialized_attr :convicted, :convicted_restored, :convicted_in_state, :convicted_rights_restored_on
  serialized_attr :mental,    :mental_restored,    :mental_rights_restored_on

  # Identity
  serialized_attr :title, :first_name, :middle_name, :last_name, :suffix
  serialized_attr :dob, :gender, :ssn, :dln, :no_ssn, :no_dln
  serialized_attr :phone, :email

end
