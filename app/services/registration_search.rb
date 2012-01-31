# Searches for existing registrations with given attributes
class RegistrationSearch

  SEED_DATA = {
    '1' => Registration.new(
      first_name:         'Wanda',
      middle_name:        'Hunt',
      last_name:          'Phepts',
      suffix_name_text:   'III',
      phone:              '540-555-1212',
      gender:             'f',
      dob:                Date.parse('1927-11-06 00:00:00.000'),
      party_affiliation:  'Democrat',
      voting_address:     '518 Vance St, Bristol, VA 242012445',
      mailing_address:    '518 Vance St, Bristol, VA 242012445'),

    '2' => Registration.new(
      first_name:         'Jack',
      last_name:          'Morgan',
      phone:              '555-555-5555',
      gender:             'm',
      dob:                Date.parse('1947-11-06 00:00:00.000'),
      party_affiliation:  'Republican',
      voting_address:     '518 Oak St, Bristol, VA 242012445',
      mailing_address:    '518 Oak St, Bristol, VA 242012445',
      absentee:           true),

    '3' => Registration.new(
      first_name:         'Michael',
      last_name:          'Phepts',
      phone:              '540-555-1200',
      gender:             'm',
      dob:                Date.parse('1937-11-06 00:00:00.000'),
      party_affiliation:  'Democrat',
      voting_address:     '518 Vance St, Bristol, VA 242012445',
      mailing_address:    '518 Vance St, Bristol, VA 242012445',
      absentee:           true,
      uocava:             true),
  }

  def self.perform(search_query)
    # TODO replace this hack we use for tests with real search
    SEED_DATA[search_query.voter_id]
  end

end
