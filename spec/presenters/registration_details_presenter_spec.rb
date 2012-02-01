require 'spec_helper'

describe RegistrationDetailsPresenter do

  describe '#party_affiliation' do
    specify { rdp(party_affiliation: '').party_affiliation.should == 'Not stated' }
    specify { rdp(party_affiliation: 'Democrat').party_affiliation.should == 'Democrat' }
  end

  describe '#status_label' do
    specify { rdp(absentee: true).status_label.should == 'Absentee Status' }
    specify { rdp(absentee: false).status_label.should == 'Voter Status' }
    specify { rdp(absentee: false, uocava: true).status_label.should == 'Absentee Status' }
  end

  describe '#absentee_status' do
    specify { rdp(absentee: false, uocava: false).absentee_status.should == 'Active' }
    specify { rdp(absentee: true,  uocava: false).absentee_status.should == 'Resident Absentee Voter' }
    specify { rdp(absentee: true,  uocava: true).absentee_status.should  == 'Overseas Absentee Voter' }
    specify { rdp(absentee: false, uocava: true).absentee_status.should  == 'Expired' }
  end

  private

  def rdp(data)
    RegistrationDetailsPresenter.new(Factory.build(:registration, data))
  end

end
