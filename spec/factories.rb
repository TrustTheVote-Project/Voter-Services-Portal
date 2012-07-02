FactoryGirl.define do
  factory :registration do |f|
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
