class QueuedVoter < ActiveRecord::Base

  has_many :reports, class_name: 'QueuedVoterReport', dependent: :delete_all

  validates :voter_id, presence: true
  validates :token, presence: true

  attr_accessible :token

  before_validation :init_token, on: 'create'

  private

  def init_token
    self.token = SecureRandom.uuid
  end

end
