require 'spec_helper'

describe VriAdapter do

  VRI_ON_MATCH_RESPONSE =
    {
      "voter_records_response" => {
        "registration_success" => {
          "action" => "registration-matched",
          "voter_registration" => {
            "registration_address" => {
              "numbered_thoroughfare_address" => {
                "complete_address_number" => {"address_number" => "123"},
                "complete_street_name" => {
                  "street_name" => "Walnut",
                  "street_name_post_type" => "Avenue",
                  "street_name_post_directional" => "Northwest"
                },
                "complete_sub_address" => {
                  "sub_address_type" => "APT",
                  "sub_address" => "#2"
                },
                "complete_place_names" => [
                  {
                    "place_name_type" => "MunicipalJurisdiction",
                    "place_name_value" => "Stittsville"
                  },
                  {
                    "place_name_type" => "County",
                    "place_name_value" => "Carleton"
                  }
                ],
                "state" => "Ontario",
                "zip_code" => "K2M3C4"
              }
            },
            "registration_address_is_mailing_address" => true,
            "name" => {
              "first_name" => "Aaron",
              "last_name" => "Huttner",
              "middle_name" => "Bernard",
              "title_prefix" => "Mr",
              "title_suffix" => "Jr"
            },
            "gender" => "male",
            "voter_ids" => [
              {
                "type" => "drivers_license",
                "attest_no_such_id" => false
              },
              {
                "type" => "other",
                "othertype" => "elector_id",
                "string_value" => "1234",
                "attest_no_such_id" => false
              }
            ],
            "voter_classifications" => [
              {"Assertion" => "true", "Type" => "Other", "OtherType" => "citizen"},
              {"Assertion" => "true", "Type" => "Other", "OtherType" => "resident-of-ontario"}
            ],
            "contact_methods" => [
              {"type" => "phone", "value" => "555-555-5555", "capabilities" => ["voice", "fax", "sms"]},
              {"type" => "email", "value" => "xyz@gmail.com"}
            ]
          }
        }
      }
    }

  REGISTRATION_DATA = {
    :voter_id => "1234",
    :current_residence => "in",
    :first_name => "Aaron",
    :middle_name => "Bernard",
    :last_name => "Huttner",
    :name_suffix => "Jr",
    :phone => "555-555-5555",
    :gender => "Male",
    :vvr_address_1 => "123 Walnut",
    :vvr_county_or_city => "Carleton",
    :vvr_state => "Ontario",
    :ma_is_different => "0",
    :is_confidential_address => "1",
    :ca_type => "TSC"
  }

  VRI_ON_NOT_MATCH_RESPONSE =
    JSON.parse('{"voter_records_response": { "registration_rejection" : {"error" : "no-match" }}}')

  describe 'to_registration' do
  subject { VriAdapter.new(response).to_registration }


  context 'match response' do
    let(:response) { VRI_ON_MATCH_RESPONSE }

    it 'accepts match response' do
      expect(subject).to be_instance_of(Registration)
      expect(subject.data).to include(REGISTRATION_DATA)
    end
  end

  context 'match response' do
    let(:response) { VRI_ON_NOT_MATCH_RESPONSE }

    it 'raises error' do
      expect { subject }.to raise_error(LookupApi::RecordNotFound)
    end
  end
  end

  describe "VSG integration" do
    subject { VriAdapter.new(response).to_registration }

    context "registration_success" do
      let(:response) do
        {
            "registration_success" => {
                "action" => "registration-matched",
                "voter_registration" => {
                    "registration_address" => {
                        "numbered_thoroughfare_address" => {
                            "complete_address_number" => {
                                "address_number" => 30
                            },
                            "complete_street_name" => {
                                "street_name" => "HENLEY",
                                "street_name_post_type" => "DR",
                                "street_name_post_directional" => nil
                            },
                            "complete_sub_address" => {
                                "sub_address_type" => "FIX_ME",
                                "sub_address" => nil
                            }, "complete_place_names" => [
                                {"place_name_type" => "MunicipalJurisdiction", "place_name_value" => "KING"},
                                {"place_name_type" => "County", "place_name_value" => "FIX_ME"}
                            ],
                            "state" => "ON",
                            "zip_code" => "L0G1N0"
                        }
                    },
                    "registration_address_is_mailing_address" => true,
                    "name" => {"first_name" => "JERRY", "last_name" => "HAQ", "middle_name" => "FERNARD", "title_prefix" => "NO_DATA", "title_suffix" => "NO_DATA"},
                    "gender" => "M",
                    "voter_ids" => [
                        {"type" => "drivers_license", "attest_no_such_id" => false},
                        {"type" => "other", "othertype" => "elector_id", "string_value" => "9745", "attest_no_such_id" => false}
                    ],
                    "voter_classifications" => ["citizen", "resident-of-ontario"],
                    "contact_methods" => [
                        {"type" => "phone", "value" => "NO_DATA", "capabilities" => ["voice", "fax", "sms"]},
                        {"type" => "email", "value" => "NO_DATA"}
                    ]
                }
            }
        }
      end

      it 'does not raise any error' do
        expect { subject }.not_to raise_error
      end
    end

    context "registration_rejection" do
      let(:response) do
        {
            "voter_records_response" => {
                "registration_rejection" => {
                    "error" => "no-match"
                }
            }
        }
      end

      it 'raises record not found error' do
        expect { subject }.to raise_error(LookupApi::RecordNotFound)
      end
    end

  end
end
