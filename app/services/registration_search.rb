# Searches for existing registrations with given attributes
class RegistrationSearch

  SEED_DATA = {
    '1234123412341234' => {
      first_name:         'Wanda',
      middle_name:        'Hunt',
      last_name:          'Phepts',
      suffix:             'III',
      phone:              '540-555-1212',
      gender:             'f',
      dob:                Date.parse('1950-11-06 00:00:00.000'),
      party_affiliation:  'Democrat',
      ssn4:               '6789',

      vvr_street_number:  '518',
      vvr_street_name:    'Vance',
      vvr_street_type:    'ST',
      vvr_county_or_city: 'Bristol City',
      vvr_state:          'VA',
      vvr_zip5:           '24201',
      vvr_zip4:           '2445',

      ma_is_same:         'yes'
    }
  }

  def self.perform(search_query)
    # TODO replace this hack we use for tests with real search
    data = unless search_query.voter_id.blank?
      search_by_voter_id(search_query.voter_id)
    else
      search_by_data(search_query)
    end

    data ? Registration.new(data.merge(existing: true)) : nil
  end

  def self.search_by_voter_id(vid)
    data = SEED_DATA[vid.gsub(/[^\d]/, '')]
    data
  end

  def self.search_by_data(query)
    k, v = SEED_DATA.to_a.find do |vid, data|
      data[:last_name].to_s.downcase == query.last_name.to_s.downcase &&
      data[:ssn4].to_s == query.ssn4.to_s &&
      data[:dob] == query.dob
    end

    v
  end
end
