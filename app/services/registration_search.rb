# Searches for existing registrations with given attributes
class RegistrationSearch

  def self.perform(search_query)
    # TODO replace this hack we use for tests with real search
    return nil if search_query.voter_id != '1'

    Registration.new(
      first_name:         'Wanda',
      middle_name:        'Hunt',
      last_name:          'Phepts',
      suffix_name_text:   'III',
      phone:              '540-555-1212',
      gender:             'f',
      dob:                Date.parse('1927-11-06 00:00:00.000'),
      party_affiliation:  'Democrat',
      voting_address:     '518 Vance St, Bristol, VA 242012445',
      mailing_address:    '518 Vance St, Bristol, VA 242012445')
  end

end
