class Registration < ActiveRecord::Base

  scope :stale, lambda { where([ "created_at < ?", 1.day.ago ]) }

  attr_accessible :first_name, :middle_name, :last_name, :suffix_name_text, :ssn

  # Flags
  attr_accessor :citizen, :age, :convicted
  attr_accessor :convicted_state, :rights_restored_at
  attr_accessor :residence
  attr_accessor :dob, :gender
  attr_accessor :identify_by, :dln
  attr_accessor :phone, :email

  def full_name
    [ first_name, middle_name, last_name, suffix_name_text ].delete_if(&:blank?).join(' ')
  end

end
