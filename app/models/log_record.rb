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

  # Parsing error logging
  def self.parsing_error(voter_id, details)
    LogRecord.create(
      doctype:    'Internal error',
      action:     '',
      voter_id:   voter_id,
      voter_type: '',
      notes:      details)
  end

  def self.lookup_timeout(uri)
    LogRecord.create(
      doctype:    'Internal error',
      action:     '',
      voter_id:   '',
      voter_type: '',
      notes:      "Lookup timeout: #{uri.to_s}")
  end

  def self.lookup_error(body)
    LogRecord.create(
      doctype:    'Internal error',
      action:     '',
      voter_id:   '',
      voter_type: '',
      notes:      "Unknown lookup error: #{body}")
  end

end
