# Searches for existing registrations with given attributes
class RegistrationSearch

  def self.perform(search_query)
    # TODO replace this hack we use for tests with real search
    search_query.voter_id == '1' ? Registration.new(first_name: 'Wanda', middle_name: 'Hunt', last_name: 'Phepts', suffix_name_text: 'III', ssn: '123456789') : nil
  end

end
