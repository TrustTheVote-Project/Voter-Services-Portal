require 'spec_helper'

describe QueuedVoterReport do

  it { should validate_presence_of :queued_voter }
  it { should validate_presence_of :polling_location_id }
  it { should validate_presence_of :arrived_on }

  it { should belong_to :queued_voter }

end
