class SearchQuery

  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :voter_id
  attr_accessor :locality, :first_name, :last_name, :dob, :ssn4

  attr_accessible :voter_id, :locality, :first_name, :last_name, :dob, :ssn4

  validates :locality,    presence: { unless: :using_voter_id? }
  validates :last_name,   presence: { unless: :using_voter_id? }
  validates :dob,         presence: { unless: :using_voter_id? }
  validates :ssn4,        presence: { unless: :using_voter_id? }

  def initialize(attrs = {})
    assign_attributes(attrs)
  end

  # Secure mass attribute assignment
  def assign_attributes(at)
    at = SearchQuery.convert_date(at, :dob)

    sanitize_for_mass_assignment(at).each do |k, v|
      send("#{k.to_s.gsub(%r{\(\)}, '')}=", v)
    end
  end

  # Returns TRUE if we are supposed to search by voter id
  def using_voter_id?
    self.voter_id.present?
  end

  def self.convert_date(attrs, key)
    y = attrs.delete("#{key}(1i)")
    m = attrs.delete("#{key}(2i)")
    d = attrs.delete("#{key}(3i)")

    begin
      attrs[key] = Date.parse([ y, m, d ] * '-')
    rescue
      # invalid date
    end

    attrs
  end

  def to_key
    nil
  end

end
