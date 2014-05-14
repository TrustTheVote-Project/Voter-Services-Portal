class QueuedVoterReport < ActiveRecord::Base

  belongs_to :queued_voter

  validates :queued_voter, presence: true
  validates :polling_location_id, presence: true
  validates :arrived_at, presence: true

  attr_accessible :arrived_at, :cancelled_at, :completed_at, :polling_location_id

  scope :completed, -> { where('completed_at IS NOT NULL') }
  scope :waiting,   -> { where('completed_at IS NULL') }

  def waited
    return nil if self.completed_at.nil? || self.arrived_at.nil?
    (self.completed_at - self.arrived_at).to_i
  end

end
