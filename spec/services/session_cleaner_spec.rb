require 'spec_helper'

describe SessionCleaner do

  it 'should return stale registrations' do
    fresh = Factory(:registration)

    stale = nil
    Timecop.travel(2.days.ago) do
     stale = Factory(:registration)
    end

    SessionCleaner.perform

    Registration.all.should == [ fresh ]
  end

end
