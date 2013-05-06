require 'spec_helper'

describe SessionCleaner do

  it 'should return stale registrations' do
    fresh = FactoryGirl.create(:registration)

    stale = nil
    Timecop.travel(2.days.ago) do
     stale = FactoryGirl.create(:registration)
    end

    SessionCleaner.perform

    Registration.all.should == [ fresh ]
  end

end
