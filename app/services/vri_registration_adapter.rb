class VriRegistrationAdapter
  SAMPLE_REG_DATA = {
      :eligibility_requirement_canadian_citizen => "1",
      :eligibility_requirement_aged_18 => "1",
      :eligibility_requirement_on_resident => "1",
      :no_doc_image => "1",
      :name_prefix => "III",
      :first_name => "GN",
      :middle_name => "x",
      :last_name => "LN",
      :name_suffix => "Mr",
      :gender => "male",
      :email => "email@email.me",
      :phone => "123-123-1234",
      :fax => "",
      :ca_address_type => "1",
      :ca_address_street_number => "112",
      :ca_address_street_name => "Street Name",
      :ca_address_street_type => "Street",
      :ca_address_direction => "South",
      :ca_address_unit => "Apt1",
      :vvr_town => "Town",
      :vvr_state => "ON",
      :vvr_zip5 => "Q1Q 1Q1",
      :ma_is_different => "1",
      :ca_ma_option => "Civic Address",
      :ca_ma_street_number => "11",
      :ca_ma_street_name => "MailStr",
      :ca_ma_street_type => "Avenue",
      :ca_ma_direction => "North",
      :ca_ma_unit => "Apt2",
      :ca_ma_town => "MTown2",
      :ca_ma_state => "ON",
      :ca_ma_zip5 => "Q2Q 2Q2",
      :information_correct => "1",
      :dob => "Tue, 01 Feb 1983",
      :id_document_image => {"mime_type" => "", "data" => ""}
  }

  def initialize(registration)
    @source = OpenStruct.new(registration.data)
  end

  def to_request
    {
        "voter_records_request" => {
            "generated_date" => Time.now.iso8601,
            "type" => "registration",
            "request_source" => {
                "name" => "Elections Ontario",
                "type" => "voter-via-internet"
            },
            "voter_registration" => {
                "date_of_birth" => @source.dob,
                "registration_address" => {
                    "numbered_thoroughfare_address" => {
                        "complete_address_number" => {
                            "address_number" => @source.ca_address_street_number
                        },
                        "complete_street_name" => {
                            "street_name" => @source.ca_address_street_name,
                            "street_name_post_type" => @source.ca_address_street_type,
                            "street_name_post_directional" => @source.ca_address_direction
                        },
                        "complete_sub_address" => {
                            "sub_address_type" => "APT",
                            "sub_address" => @source.ca_address_unit
                        },
                        "complete_place_names" => [
                            # {
                            #     "place_name_type" => "MunicipalJurisdiction",
                            #     "place_name_value" => "" #TODO TBD
                            # },
                            {
                                "place_name_type" => "County",
                                "place_name_value" => @source.vvr_town
                            }
                        ],
                        "state" => @source.vvr_state,
                        "zip_code" => @source.vvr_zip5
                    }
                },
                "mailing_address" => @source.ma_is_different == "0" ? {} : {
                    "unstructured_thoroughfare_address" => {
                        "address_lines" => [
                            [
                                @source.ca_ma_street_number,
                                @source.ca_ma_street_name,
                                @source.ca_ma_unit
                            ].join(" "),
                            [
                                @source.ca_ma_town,
                                @source.ca_ma_state,
                                @source.ca_ma_zip5
                            ].join(" ")

                        ],
                        "complete_place_names" => [
                            # {
                            #     "place_name_type" => "MunicipalJurisdiction",
                            #     "place_name_value" => "" # TODO TBD
                            # },
                            {
                                "place_name_type" => "County",
                                "place_name_value" => @source.ca_ma_town
                            }
                        ],
                        "state" => @source.ca_ma_state,
                        "zip_code" => @source.ca_ma_zip5
                    }
                },
                "registration_address_is_mailing_address" => @source.ma_is_different == "0",
                "name" => {
                    "first_name" => @source.first_name,
                    "last_name" => @source.last_name,
                    "middle_name" => @source.middle_name,
                    "title_prefix" => @source.name_prefix,
                    "title_suffix" => @source.name_suffix
                },
                "gender" => @source.gender,
                "voter_ids" => (@source.no_doc_image == "1") ? [] : [
                    {
                        "type" => @source.id_document_image_type, # e.g. "drivers_license",
                        "file_value" => {
                            "mime_type" => @source.id_document_image["mime_type"],
                            "data" => @source.id_document_image["data"]
                        },
                        "attest_no_such_id" => false
                    }
                ],
                "voter_classifications" => [
                    {
                        "Assertion" => @source.eligibility_requirement_aged_18 == "1",
                        "Type" => "eighteen-on-election_day"
                    },
                    {
                        "Assertion" => @source.eligibility_requirement_canadian_citizen == "1",
                        "Type" => "Other",
                        "OtherType" => "citizen"
                    },
                    {
                        "Assertion" => @source.eligibility_requirement_on_resident == "1",
                        "Type" => "Other",
                        "OtherType" => "resident-of-ontario"
                    }
                #,
                # {
                #     "Assertion" => "true",
                #     "Type" => "Other",
                #     "OtherType" => "assented-to-declaration" # TODO TBD?
                # }
                ],
                "contact_methods" => [
                    @source.phone.empty? ? nil : {
                        "type" => "phone",
                        "value" => @source.phone,
                        "capabilities" => [
                            "voice"
                        # ,
                        # "fax",
                        # "sms"
                        ]
                    },
                    # TODO TBD - do we need this?
                    # @source.fax.empty? ? {} : {
                    #     "type" => "phone",
                    #     "value" => @source.fax,
                    #     "capabilities" => [
                    #         "fax"
                    #     ]
                    # },
                    @source.email.empty? ? nil : {
                        "type" => "email",
                        "value" => @source.email
                    }
                ].compact
            }
        }
    }
  end

end