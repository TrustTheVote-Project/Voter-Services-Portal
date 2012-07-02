require 'spec_helper'

describe Registration do

  describe 'full_name' do
    specify { Factory.build(:registration, first_name: 'Wanda', middle_name: 'Hunt', last_name: 'Phelps', suffix: 'III').full_name.should == 'Wanda Hunt Phelps III' }
    specify { Factory.build(:registration, first_name: 'John', last_name: 'Smith').full_name.should == 'John Smith' }
  end

  describe 'saving previous data' do
    let(:reg) { Factory(:registration) }

    specify { reg.previous_data.should be_nil }
    it "should save previous value on update" do
      previous_first_name = reg.first_name
      reg.update_attributes(first_name: 'Mike')
      reg.reload
      reg.previous_data[:first_name].should == previous_first_name
    end
  end

  describe 'init_update_to' do
    let(:r) { FactoryGirl.create(:registration, :domestic_absentee) }

    it 'should handle no kind (no status change)' do
      r.init_update_to(nil)
      r.should be_absentee
      r.should be_residential
      r.should be_can_officiate
    end

    it 'should handle domestic_absentee' do
      r.init_update_to('domestic_absentee')
      r.should be_absentee
      r.should be_residential
      r.should be_can_officiate
    end

    it 'should handle residential_voter' do
      r.init_update_to('residential_voter')
      r.should_not be_absentee
      r.should be_residential
      r.should be_can_officiate
    end

    it 'should handle overseas' do
      r.init_update_to('overseas')
      r.should be_absentee
      r.should_not be_residential
      r.should be_can_officiate
    end

    it 'should set can_officiate if overseas and status does not change' do
      r = FactoryGirl.create(:registration, :overseas)
      r.init_update_to('overseas')
      r.should_not be_can_officiate
      r.should_not be_can_change_registration_address
    end
  end

  describe 'defaults for flags' do
    subject { Registration.new }
    its(:can_change_registration_address) { should be_true }
    its(:can_officiate) { should be_true }
  end

end
