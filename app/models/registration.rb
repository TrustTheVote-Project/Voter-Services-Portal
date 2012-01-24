class Registration < ActiveRecord::Base

  scope :stale, lambda { where([ "created_at < ?", 1.day.ago ]) }

  attr_accessible :voter_id

  def full_name
    [ first_name, middle_name, last_name, suffix_name_text ].delete_if(&:blank?).join(' ')
  end

end
