require 'spec_helper'

describe RegistrationDetailsPresenter do

  describe '#party' do
    specify { rdp(party: '').party.should == '(none)' }
    specify { rdp(party: 'Democrat').party.should == 'Democrat' }
    specify { rdp(party: 'other', other_party: 'Choppers').party.should == 'Choppers' }
  end

  describe '#registration_status' do
    specify { rdp(absentee: true, uocava: true).registration_status.should == 'Overseas Absentee Voter' }
    specify { rdp(absentee: true, uocava: false).registration_status.should == 'Resident Absentee Voter' }
    specify { rdp(absentee: false).registration_status.should == 'You are currently registered to vote in person' }
  end

  describe "status_options" do
    it "should place overseas before everything else" do
      rdp(absentee: true, uocava: true).status_options.should == [ "overseas", "separator", "residential_voter", "residential_absentee" ]
    end
  end

  private

  def rdp(data)
    RegistrationDetailsPresenter.new(Factory.build(:registration, data))
  end

end
