class Registration < ActiveRecord::Base

  def full_name
    [ first_name, middle_name, last_name, suffix_name_text ].delete_if(&:blank?).join(' ')
  end

end
