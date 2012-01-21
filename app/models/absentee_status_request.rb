class AbsenteeStatusRequest

  include ActiveModel::Validations
  #include ActiveModel::MassAssignmentSecurity

  attr_accessor :full_name, :ssn1, :ssn2, :ssn3, :vote_in, :location_type, :location_name, :vote_on

  def to_key
    nil
  end

end
