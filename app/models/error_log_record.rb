class ErrorLogRecord < ActiveRecord::Base

  serialize :details

  attr_accessible :message, :details

  validates :message, presence: true

  # creates the log record
  def self.log(message, details)
    create(message: message, details: details)
  end

end
