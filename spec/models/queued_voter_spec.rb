require 'spec_helper'

describe QueuedVoter do

  it { should validate_presence_of :token }

  it { should have_many :reports }

end
