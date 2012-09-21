FactoryGirl.define do
  factory :registration do |f|
    trait :existing do
      voter_id '1'
    end

    trait :residential_voter do
      residence           'in'
      requesting_absentee '0'
    end

    trait :domestic_absentee do
      residence           'in'
      requesting_absentee '1'
    end

    trait :overseas do
      residence           'outside'
      requesting_absentee '1'
    end

    factory :existing_residential_voter do
      voter_id            '123123123'
      current_residence   'in'
      first_name          'Wanda'
      middle_name         'Hunt'
      last_name           'Phepts'
      suffix              'III'
      phone               '540-555-1212'
      gender              'Female'
      dob                 Date.parse('1950-11-06 00:00:00.000')
      choose_party        '1'
      party               'Democratic Party'
      ssn4                '6789'

      vvr_street_number   '518'
      vvr_street_name     'Vance'
      vvr_street_type     'ST'
      vvr_county_or_city  'BRUNSWICK COUNTY'
      vvr_town            'Queensberry'
      vvr_state           'VA'
      vvr_zip5            '24201'
      vvr_zip4            '2445'
      vvr_is_rural        '0'

      ma_is_same          '0'
      ma_address          '518 Vance St'
      ma_city             'Queensberry'
      ma_state            'VA'
      ma_zip5             '24201'
      ma_zip4             '2445'

      has_existing_reg    '0'

      is_confidential_address '1'
      ca_type             'TSC'
      ca_po_box           '20031'
      ca_city             'Harrisonburg'
      ca_zip5             '22801'
      ca_zip4             '7531'

      be_official         '1'

      existing            true

      poll_locality       "BRUNSWICK COUNTY"
      poll_precinct       "220 - RATCLIFFE"
      poll_district       "FAIRFIELD DISTRICT"

      districts           [ [ 'Congressional',  [ '09', '9th District' ] ],
                            [ 'Senate',         [ '038', '38th District' ] ],
                            [ 'State House',    [ '003', '3rd District' ] ],
                            [ 'Local',          [ '', 'SOUTHERN DISTRICT' ] ] ]

      past_elections      [ [ '2007 November', 'Absentee' ] ]
      ready_for_online_balloting true
    end

    factory :existing_overseas_voter do
      voter_id            '111222333'
      current_residence   'outside'
      first_name          'Overseas'
      last_name           'Marine'
      gender              'Male'
      dob                 40.years.ago
      ssn4                '1234'

      vvr_street_number   '5'
      vvr_street_name     'First'
      vvr_street_type     'ST'
      vvr_county_or_city  'BRISTOL CITY'
      vvr_state           'VA'
      vvr_zip5            '12345'
      vvr_zip4            ''
      vvr_is_rural        '0'

      vvr_uocava_residence_available '0'
      vvr_uocava_residence_unavailable_since 5.years.ago

      mau_type            'apo'
      apo_address         'Apo street'
      apo_1               'APO'
      apo_2               'AA'
      apo_zip5            '23456'

      outside_type        'ActiveDutyMerchantMarineOrArmedForces'
      service_branch      'Army'
      service_id          '112233'
      rank                'Major'

      has_existing_reg    '0'
      current_absentee_until 2.months.from_now

      existing            true

      poll_locality       "LOUDOUN COUNTY"
      poll_precinct       "301 - PURCELLVILLE ONE"
      poll_district       "BLUE RIDGE DISTRICT"

      districts           [ [ 'Congressional',  [ '09', '9th District' ] ],
                            [ 'Senate',         [ '038', '38th District' ] ],
                            [ 'State House',    [ '003', '3rd District' ] ],
                            [ 'Local',          [ '', 'SOUTHERN DISTRICT' ] ] ]

      past_elections      [ [ '2007 November', 'Absentee' ] ]
    end
  end
end
