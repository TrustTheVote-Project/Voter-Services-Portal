class Setting < ActiveRecord::Base

  def self.[](name)
    Setting.find_by_name(name).try(:value)
  end

  def self.[]=(name, value)
    raise "Name can't be blank" if name.blank?

    s = Setting.find_or_initialize_by_name(name)
    s.update_attributes!(value: value)
  end

  def self.marking_ballot_online?
    !Setting['marking_ballot_online'].blank?
  end

  def self.marking_ballot_online=(flag)
    Setting['marking_ballot_online'] = flag ? '1' : nil
  end

end
