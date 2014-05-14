require 'spec_helper'

describe QueuedVoter do

  it { should validate_presence_of :voter_id }
  it { should have_many :reports }

  it 'should generate token on create' do
    v = QueuedVoter.create
    expect(v.token).to_not be_blank
  end

end
