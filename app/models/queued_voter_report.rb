class QueuedVoterReport < ActiveRecord::Base

  belongs_to :queued_voter

  validates :queued_voter, presence: true
  validates :polling_location_id, presence: true
  validates :arrived_on, presence: true

  attr_accessible :arrived_on, :cancelled_on, :completed_on, :polling_location_id

end
