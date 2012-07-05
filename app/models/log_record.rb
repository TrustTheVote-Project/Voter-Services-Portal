class LogRecord < ActiveRecord::Base

  serialize :details

  attr_accessible :voter_id, :voter_type, :doctype, :action, :notes

  # Makes a log record
  def self.log(doctype, action, reg = nil, notes = nil)
    LogRecord.create(
      doctype:    doctype,
      action:     action,
      voter_id:   reg.try(:voter_id),
      voter_type: reg.try(:voter_type),
      notes:      notes)
  end

end
