class QueuedVoter < ActiveRecord::Base

  has_many :reports, class_name: 'QueuedVoterReport', dependent: :delete_all

  validates :token, presence: true

  attr_accessible :token

end
