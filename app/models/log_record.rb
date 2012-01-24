class LogRecord < ActiveRecord::Base

  serialize :details

  # Makes a log record
  def self.log(subject, action, details = nil)
    LogRecord.create(subject: subject, action: action, details: details)
  end

end
