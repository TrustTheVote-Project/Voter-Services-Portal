class LogRecord < ActiveRecord::Base

  serialize :details

  attr_accessible :action, :voter_id, :form, :form_type, :form_note, :jurisdiction, :notes

  # Makes a log record
  def self.log(form, action, reg = nil, notes = nil)
    LogRecord.create(
      form:       form,
      action:     action,
      voter_id:   reg.try(:voter_id),
      form_type:  reg.try(:voter_type),
      notes:      notes)
  end

  def self.identify(reg, locality)
    LogRecord.create(
      action:     'identify',
      voter_id:   reg.voter_id,
      jurisdiction: locality,
      notes:      'onlineVoterReg')
  end

  def self.start_update(reg)
    LogRecord.create(
      action:     'start',
      form:       'VoterRegistration',
      form_note:  'onlineGenerated',
      voter_id:   reg.voter_id,
      jurisdiction: reg.poll_locality)
  end

  def self.start_new(overseas)
    LogRecord.create(
      action:     'start',
      form:       overseas ? 'VoterRecordUpdateAbsenteeRequest' : 'VoterRegistration',
      form_note:  'onlineGenerated')
  end

  def self.complete_update(reg)
    LogRecord.create(
      action:     'complete',
      form:       reg.uocava? ? 'AbsenteeRequest' : 'VoterRecordUpdate',
      form_note:  'onlineGenerated',
      voter_id:   reg.voter_id,
      jurisdiction: reg.vvr_county_or_city)
  end

  def self.complete_new(reg)
    LogRecord.create(
      action:     'complete',
      form:       reg.uocava? ? 'VoterRecordUpdateAbsenteeRequest' : 'VoterRecordUpdate',
      form_note:  'onlineGenerated',
      jurisdiction: reg.vvr_county_or_city)
  end

  def self.absentee_request(reg)
    form = reg.uocava? || !reg.no_form_changes? ? 'VoterRecordUpdateAbsenteeRequest' : 'AbsenteeRequest'

    LogRecord.create(
      action:     'start',
      voter_id:   reg.voter_id,
      form:       form,
      form_note:  'onlineGenerated',
      jurisdiction: reg.vvr_county_or_city)

    LogRecord.create(
      action:     'complete',
      voter_id:   reg.voter_id,
      form:       form,
      form_note:  'onlineGenerated',
      jurisdiction: reg.vvr_county_or_city)
  end

  # Parsing error logging
  def self.parsing_error(voter_id, details)
    LogRecord.create(
      action:     'parsing',
      form:       'InternalError',
      voter_id:   voter_id,
      notes:      details)
  end

  def self.lookup_timeout(uri)
    LogRecord.create(
      action:     'lookup',
      form:       'InternalError',
      notes:      "Lookup timeout: #{uri.to_s}")
  end

  def self.lookup_error(body)
    LogRecord.create(
      action:     'lookup',
      form:       'InternalError',
      notes:      "Unknown lookup error: #{body}")
  end

end
