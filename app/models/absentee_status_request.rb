class AbsenteeStatusRequest

  include ActiveModel::Validations

  attr_accessor :full_name, :ssn, :vote_in, :location_type, :location_name, :vote_on

  def to_key
    nil
  end

end
