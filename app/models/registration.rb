class Registration < ActiveRecord::Base

  scope :stale, lambda { where([ "created_at < ?", 1.day.ago ]) }

  attr_accessor :ssn4, :suffix

  attr_accessible :voter_id
  attr_accessible :first_name, :middle_name, :last_name, :suffix
  attr_accessible :email, :phone, :gender, :dob, :party_affiliation, :voting_address, :mailing_address, :ssn4
  attr_accessible :absentee, :uocava

  def full_name
    [ first_name, middle_name, last_name, suffix ].delete_if(&:blank?).join(' ')
  end

end
