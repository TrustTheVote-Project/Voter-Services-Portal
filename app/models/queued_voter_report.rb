class QueuedVoterReport < ActiveRecord::Base

  belongs_to :queued_voter

  validates :queued_voter, presence: true
  validates :polling_location_id, presence: true
  validates :arrived_at, presence: true

  attr_accessible :arrived_at, :cancelled_at, :completed_at, :polling_location_id

end
