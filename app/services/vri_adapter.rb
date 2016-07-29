class VriAdapter
  # sample match response
  # VRI_ON_RESPONSE =
  #   {
  #     :voter_records_response => {
  #       :registration_success => {
  #         :action => "registration-matched",
  #         :voter_registration => {
  #           :registration_address => {
  #             :numbered_thoroughfare_address => {
  #               :complete_address_number => {:address_number => "123"},
  #               :complete_street_name => {
  #                 :street_name => "Walnut",
  #                 :street_name_post_type => "Avenue",
  #                 :street_name_post_directional => "Northwest"
  #               },
  #               :complete_sub_address => {
  #                   :sub_address_type => "APT",
  #                   :sub_address => "#2"
  #               },
  #               :complete_place_names => [
  #                   {
  #                     :place_name_type => "MunicipalJurisdiction",
  #                     :place_name_value => "Stittsville"
  #                   },
  #                   {
  #                     :place_name_type => "County",
  #                     :place_name_value => "Carleton"
  #                   }
  #               ],
  #               :state => "Ontario",
  #               :zip_code => "K2M3C4"
  #             }
  #           },
  #           :registration_address_is_mailing_address => true,
  #           :name => {
  #             :first_name => "Aaron",
  #             :last_name => "Huttner",
  #             :middle_name => "Bernard",
  #             :title_prefix => "Mr",
  #             :title_suffix => "Jr"
  #           },
  #           :gender => "male",
  #           :voter_ids => [
  #               {
  #                 :type => "drivers_license",
  #                 :attest_no_such_id => false
  #               },
  #               {
  #                 :type => "other",
  #                 :othertype => "elector_id",
  #                 :string_value => "1234",
  #                 :attest_no_such_id => false
  #               }
  #           ],
  #           :voter_classifications => [
  #               {:Assertion => "true", :Type => "Other", :OtherType => "citizen"},
  #               {:Assertion => "true", :Type => "Other", :OtherType => "resident-of-ontario"}
  #           ],
  #           :contact_methods => [
  #             {:type => "phone", :value => "555-555-5555", :capabilities => ["voice", "fax", "sms"]},
  #             {:type => "email", :value => "xyz@gmail.com"}
  #           ]
  #         }
  #       }
  #     }
  #   }.stringify_keys!

  def to_registration
    Registration.new(data: {
        :voter_id => voter_id,
        :current_residence => "in", # TODO analyze voter_classifications # affects `currently_overseas?` and showing mail address
        :first_name => source_data['name']['first_name'],
        :middle_name => source_data['name']['middle_name'],
        :last_name => source_data['name']['last_name'],
        :name_suffix => source_data['name']['title_suffix'],
        :phone => phone,
        :gender => gender,
        # :dob => Date.new(1950, 11, 06),             # TODO ??? ## shown at registrations/show
        # :choose_party  =>  "1",                     # probably not shown at registrations/show
        # :party => "Democratic Party",               # probably not shown at registrations/show
        :vvr_address_1 => address_1,        # used in RegistrationDetailsPresenter.registration_address
        :vvr_county_or_city => county,
        # :vvr_town => "Queensberry",
        :vvr_state => source_data['registration_address']['numbered_thoroughfare_address']['state'],
        # :vvr_zip5 => "24201",
        # :vvr_zip4 => "2445",
        # :vvr_is_rural => "0",
        :ma_is_different => "0",                    # Hide Mailing Address
        # :ma_address => "518 Vance St",
        # :ma_city => "Queensberry",
        # :ma_state => "VA",
        # :ma_zip5 => "24201",
        # :ma_zip4 => "2445",
        # :pr_status => "0",                          # not shown at registrations/show
        :is_confidential_address => "1",            # TODO affects address_confidentiality? and paperless_submission_allowed?
        :ca_type => "TSC",
        # :be_official => "1",                        # probably not shown at registrations/show
        # :existing => true,
        # :poll_locality => "BRUNSWICK COUNTY",       # TODO ??? # affects registrations/show
        # :poll_precinct => "220 - RATCLIFFE",        # TODO ??? # affects registrations/show
        # :poll_district => "FAIRFIELD DISTRICT",
        # :districts => [["Congressional", ["09", "9th District"]], ["Senate", ["038", "38th District"]], ["State House", ["003", "3rd District"]], ["Local", ["", "SOUTHERN DISTRICT"]]],
        # :past_elections => [["2007 November", "Absentee"]],
        # :ob_eligible => true,
        # :absentee_for_elections => ["Election 1", "Election 2"]
    })
  end

  def initialize(vri_on_response)
    # deep (recursive) conversion to OpenStruct
    # @source = JSON.parse(vri_on_response.to_json, object_class: OpenStruct)
    @source = vri_on_response
    raise LookupApi::RecordNotFound if not_found?
  end

  def voter_id
    source_data['voter_ids'].find { |x| x['othertype'] == 'elector_id' }.try(:[], 'string_value')
  end

  def phone
    source_data['contact_methods'].find {|x| x['type'] == 'phone' }.try(:[], 'value')
  end

  def gender
    source_data['gender'].try(:capitalize)
  end

  def address_1
    [
        source_data['registration_address']['numbered_thoroughfare_address']['complete_address_number']['address_number'],
        source_data['registration_address']['numbered_thoroughfare_address']['complete_street_name']['street_name']
    ].join(' ')

  end

  def county
    source_data['registration_address']['numbered_thoroughfare_address']['complete_place_names'].find{|x| x['place_name_type'] == 'County'}.try(:[], 'place_name_value')
  end

  def source_data
    @source['voter_records_response']['registration_success']['voter_registration']
  end

  private

  def not_found?
    success = @source.try(:[], 'voter_records_response').try(:[], 'registration_success')
    success.nil? || success['action'] != 'registration-matched'
  end
end
