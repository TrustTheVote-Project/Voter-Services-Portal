# Searches for existing registrations with given attributes
class RegistrationSearch

  SEED_DATA = {
    '1234123412341234' => {
      first_name:         'Wanda',
      middle_name:        'Hunt',
      last_name:          'Phepts',
      suffix:             'III',
      phone:              '540-555-1212',
      gender:             'Female',
      dob:                Date.parse('1950-11-06 00:00:00.000'),
      choose_party:       '1',
      party:              'Democratic Party',
      ssn4:               '6789',

      vvr_street_number:  '518',
      vvr_street_name:    'Vance',
      vvr_street_type:    'ST',
      vvr_county_or_city: 'BRUNSWICK COUNTY',
      vvr_town:           'Queensberry',
      vvr_state:          'VA',
      vvr_zip5:           '24201',
      vvr_zip4:           '2445',

      ma_is_same:         'yes',

      is_confidential_address: '1',
      ca_type:            'if',

      has_existing_reg:   'no',
      be_official:        '1'
    },

    '1111222233334444' => {
      residence:          'outside',
      requesting_absentee: '1',
      first_name:         'Overseas',
      last_name:          'Marine',
      gender:             'Male',
      dob:                40.years.ago,
      ssn4:               '1234',

      vvr_street_number:  '5',
      vvr_street_name:    'First',
      vvr_street_type:    'ST',
      vvr_county_or_city: 'BRISTOL CITY',
      vvr_state:          'VA',
      vvr_zip5:           '12345',
      vvr_zip4:           '',

      vvr_uocava_residence_available: 'no',
      vvr_uocava_residence_unavailable_since: 5.years.ago,

      mau_type:           'apo',
      apo_address:        'Apo street',
      apo_1:              'APO',
      apo_2:              'AA',
      apo_zip5:           '23456',

      outside_type:       'active_duty',
      service_branch:     'Army',
      service_id:         '112233',
      rank:               'Major',

      has_existing_reg:   'no',
      absentee_until:     2.months.from_now
    },

    '4444333322221111' => {
      residence:          'in',
      requesting_absentee: '1',
      first_name:         'Domestic',
      last_name:          'Absentee',
      gender:             'Male',
      dob:                40.years.ago,
      ssn4:               '1234',

      vvr_street_number:  '5',
      vvr_street_name:    'First',
      vvr_street_type:    'ST',
      vvr_county_or_city: 'BRISTOL CITY',
      vvr_state:          'VA',
      vvr_zip5:           '12345',
      vvr_zip4:           '',

      ma_is_same:         'yes',

      is_confidential_address: '1',
      ca_type:            'if',

      rab_election:       '1',
      ab_reason:          'Reason 2',
      ab_school_name:     'St Joseph',
      ab_street_number:   '51',
      ab_street_name:     'Church',
      ab_street_type:     'ST',
      ab_apt:             '1',
      ab_city:            'Bristol',
      ab_state:           'VA',
      ab_zip5:            '12345',
      ab_zip4:            '6789',
      ab_country:         'USA',

      has_existing_reg:   'no',
      be_official:        '1'
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
