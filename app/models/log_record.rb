class LogRecord < ActiveRecord::Base

  serialize :details

  attr_accessible :subject, :action, :details

  # Makes a log record
  def self.log(subject, action, details = nil)
    LogRecord.create(subject: subject, action: action, details: details)
  end

end
