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
  end
end
