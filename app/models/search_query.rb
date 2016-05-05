class SearchQuery

  include ActiveModel::Validations
  include ActiveModel::MassAssignmentSecurity

  SearchController.helpers.lookup_service_config.tap do |lookup_config|
    if lookup_config['id_and_locality_style']
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
    else
      [:first_name, :last_name, :date_of_birth, :street_number, :street_name, :street_type, :vvr_address_1, :vvr_town, :vvr_zip5].each do |field|
        if lookup_config[field.to_s]
          attr_accessor field
          attr_accessible field
          validates field,  presence: true
        end
      end
      if lookup_config['identification_document']
        attr_accessor :id_document_number
        attr_accessible :id_document_number
        validates :id_document_number,  presence: true
        attr_accessor :id_document_type
        attr_accessible :id_document_type
        validates :id_document_type,  presence: true
      end
    end
    
  end

  def initialize(attrs = {})
    assign_attributes(attrs) unless attrs.blank?
    if SearchController.helpers.lookup_service_config['id_and_locality_style']
      self.lookup_type ||= 'ssn4'
    end
  end

  def self.from_eml310_json(json)
    eml = JSON.parse(json)

    lookup_type = from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "CheckBox", "CheckBox-Type")
    if lookup_type == 'IDbyVIDwLocalityDOB'
      lookup_type = 'vid'
    elsif lookup_type == 'IDbySSN4wFnameLnameLocalityDOB'
      lookup_type = 'ssn4'
    else
      raise InvalidArgument, "Unknown lookup type: #{lookup_type}"
    end

    if lookup_type == 'vid'
      SearchQuery.new({
        lookup_type: lookup_type,
        voter_id:    from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "VoterPhysicalID", "VoterPhysicalID-value"),
        locality:    from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "ElectoralAddress", "PostalAddress", "Locality"),
        dob:         Chronic.parse(from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "DateOfBirth")).to_date
      })
    elsif lookup_type == 'ssn4'
      SearchQuery.new({
        lookup_type: lookup_type,
        first_name:  from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "VoterName", "GivenName"),
        last_name:   from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "VoterName", "FamilyName"),
        locality:    from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "ElectoralAddress", "PostalAddress", "Locality"),
        ssn4:        from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "VoterPhysicalID", "VoterPhysicalID-value"),
        dob:         Chronic.parse(from_eml(eml, "VoterRegistration", "Voter", "VoterIdentification", "DateOfBirth")).to_date
      })
    end
  end

  # Secure mass attribute assignment
  def assign_attributes(at)
    at = SearchQuery.convert_date(at, :dob) if at[:dob].blank?
    at = SearchQuery.convert_date(at, :date_of_birth) if at[:date_of_birth].blank?

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

  def self.from_eml(eml, *chain)
    chain.inject(eml['eml']) { |m, e| m.try(:[], e) }
  end

end
