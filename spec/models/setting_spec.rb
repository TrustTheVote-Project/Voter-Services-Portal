require 'spec_helper'

describe Setting do

  it 'should store and restore a value' do
    Setting['test'] = "12"
    Setting['test'].should == "12"
  end

  it 'should update a value' do
    Setting['test'] = "13"
    Setting['test'] = "14"
    Setting['test'].should == "14"
  end

  it 'should disallow empty names' do
    lambda { Setting[nil] = 'a' }.should raise_error
    lambda { Setting[''] = 'bb' }.should raise_error
  end

  describe 'specific options' do
    it 'should set marking_ballot_online' do
      Setting.marking_ballot_online?.should be_false
      Setting.marking_ballot_online = true
      Setting.marking_ballot_online?.should be_true
      Setting.marking_ballot_online = false
      Setting.marking_ballot_online?.should be_false
    end
  end
end
