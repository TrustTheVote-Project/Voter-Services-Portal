class Registration < ActiveRecord::Base

  scope :stale, lambda { where([ "created_at < ?", 1.day.ago ]) }

  attr_accessible :first_name, :middle_name, :last_name, :suffix_name_text
  attr_accessible :email, :phone, :gender, :dob, :party_affiliation, :voting_address, :mailing_address
  attr_accessible :absentee, :uocava

  def full_name
    [ first_name, middle_name, last_name, suffix_name_text ].delete_if(&:blank?).join(' ')
  end

end
