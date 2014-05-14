class SearchQuery

  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity

  attr_accessor :lookup_type
  attr_accessor :voter_id
  attr_accessor :locality, :first_name, :last_name, :dob, :ssn4

  attr_accessible :voter_id, :locality, :first_name, :last_name, :dob, :ssn4, :lookup_type

  validates :locality,    presence: true
  validates :first_name,  presence: { unless: :using_voter_id? }
  validates :last_name,   presence: { unless: :using_voter_id? }
  validates :dob,         presence: true
  validates :ssn4,        presence: { unless: :using_voter_id? }
  validates :voter_id,    presence: {     if: :using_voter_id? }

  def initialize(attrs = {})
    assign_attributes(attrs) unless attrs.blank?
    self.lookup_type ||= 'ssn4'
  end

  # Secure mass attribute assignment
  def assign_attributes(at)
    at = SearchQuery.convert_date(at, :dob) if at[:dob].blank?

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

  def to_log_details
    [ first_name, last_name, dob.try(:strftime, "%Y-%m-%d"), locality, voter_id.blank? ? ssn4 : voter_id ].reject(&:blank?).join(' / ')
  end

  def to_key
    nil
  end

end
