require 'spec_helper'

describe RegistrationDetailsPresenter do

  describe '#party' do
    specify { rdp(party: '').party.should == '(none)' }
    specify { rdp(party: 'Democrat').party.should == 'Democrat' }
    specify { rdp(party: 'other', other_party: 'Choppers').party.should == 'Choppers' }
  end

  describe '#registration_status' do
    specify { rdp(uocava: true).registration_status.should == 'Overseas Absentee Voter' }
    specify { rdp(absentee: true,  uocava: false).registration_status.should == 'Resident Absentee Voter' }
    specify { rdp(absentee: false, uocava: false).registration_status.should == 'You are currently registered to vote in person' }
  end

  describe "status_options" do
    it "should place overseas before everything else" do
      rdp(uocava: true).status_options.should == [ "overseas", "separator", "residential_voter", "domestic_absentee" ]
    end
  end

  private

  def rdp(data)
    data[:residence]            = data.delete(:uocava) ? 'outside' : 'in'
    data[:requesting_absentee]  = (data.delete(:absentee) || data[:residence] == 'outside') ? '1' : '0'
    RegistrationDetailsPresenter.new(Factory.build(:registration, data))
  end

end
