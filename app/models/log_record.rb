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
      form:       'VoterRegistration', # using this to match the schema. shouldn't be any
      voter_id:   reg.voter_id,
      jurisdiction: locality)
  end

  def self.start_update(reg)
    return LogRecord.create(
      action:     'start',
      form:       'VoterRecordUpdate',
      voter_id:   reg.voter_id,
      jurisdiction: reg.poll_locality)
  end

  def self.start_new(reg)
    return LogRecord.create(
      action:     'start',
      form:       reg.uocava? ? 'VoterRegistrationAbsenteeRequest' : 'VoterRegistration')
  end

  def self.complete_update(reg, start_log_record_id)
    if reg.uocava? || !reg.requesting_absentee?
      form = 'VoterRecordUpdate'
    else
      form = reg.no_form_changes? ? 'AbsenteeRequest' : 'VoterRecordUpdateAbsenteeRequest'
    end

    if !reg.uocava? && reg.requesting_absentee?
      update_start_record(start_log_record_id, form)
    end

    LogRecord.create(
      action:     'complete',
      form:       form,
      voter_id:   reg.voter_id,
      jurisdiction: reg.vvr_county_or_city)
  end

  def self.complete_new(reg, start_log_record_id)
    form = reg.uocava? ? 'VoterRegistrationAbsenteeRequest' : 'VoterRegistration'

    # update start record
    update_start_record(start_log_record_id, form)

    if !reg.uocava? && reg.requesting_absentee?
      LogRecord.absentee_request(reg, :new_record)
    end

    # log completion record
    LogRecord.create(
      action:     'complete',
      form:       form,
      jurisdiction: reg.vvr_county_or_city)
  end

  def self.absentee_request(reg, new_record = false)
    if new_record
      form = 'AbsenteeRequest'
    elsif reg.uocava? || !reg.no_form_changes?
      form = 'VoterRecordUpdateAbsenteeRequest'
    else
      form = 'AbsenteeRequest'
    end

    LogRecord.create(
      action:     'start',
      voter_id:   reg.voter_id,
      form:       form,
      jurisdiction: reg.vvr_county_or_city)

    LogRecord.create(
      action:     'complete',
      voter_id:   reg.voter_id,
      form:       form,
      jurisdiction: reg.vvr_county_or_city)
  end

  def self.discard(active_form)
    LogRecord.create(
      action:       'discard',
      voter_id:     active_form.voter_id,
      form:         active_form.form,
      jurisdiction: active_form.jurisdiction)
  end

  # Parsing error logging
  def self.parsing_error(voter_id, details)
    # LogRecord.create(
    #   action:     'parsing',
    #   form:       'InternalError',
    #   voter_id:   voter_id,
    #   notes:      details)
  end

  def self.lookup_timeout(uri)
    # LogRecord.create(
    #   action:     'lookup',
    #   form:       'InternalError',
    #   notes:      "Lookup timeout: #{uri.to_s}")
  end

  def self.lookup_error(body)
    # LogRecord.create(
    #   action:     'lookup',
    #   form:       'InternalError',
    #   notes:      "Unknown lookup error: #{body}")
  end

  def self.update_start_record(start_log_record_id, form)
    start_record = LogRecord.where(id: start_log_record_id).first
    if start_record
      start_record.form = form
      start_record.save
    end
  end
end
