class LogRecord < ActiveRecord::Base

  serialize :details

  attr_accessible :voter_id, :doctype, :action, :notes

  # Makes a log record
  def self.log(doctype, action, voter_id = nil, notes = nil)
    LogRecord.create(doctype: doctype, action: action, voter_id: voter_id, notes: notes)
  end

end
