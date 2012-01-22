require 'spec_helper'

describe Registration do

  describe 'full_name' do
    specify { Factory.build(:registration, first_name: 'Wanda', middle_name: 'Hunt', last_name: 'Phelps', suffix_name_text: 'III').full_name.should == 'Wanda Hunt Phelps III' }
    specify { Factory.build(:registration, first_name: 'John', last_name: 'Smith').full_name.should == 'John Smith' }
  end

end
