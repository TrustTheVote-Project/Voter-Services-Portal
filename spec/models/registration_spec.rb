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

end
