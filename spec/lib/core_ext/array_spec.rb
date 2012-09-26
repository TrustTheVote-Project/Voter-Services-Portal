require 'spec_helper'

describe Array do

  describe 'humanized_list_join' do
    specify { [].humanized_list_join.should == '' }
    specify { [ 'el' ].humanized_list_join.should == 'el' }
    specify { [ 'a', 'b' ].humanized_list_join.should == 'a and b' }
    specify { [ 'a', 'b', 'c' ].humanized_list_join.should == 'a, b and c' }
  end

end
