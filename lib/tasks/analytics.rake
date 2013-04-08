namespace :analytics do

  desc "Generate a sample log for analytics"
  task :generate_full_sample => :environment do
    LogRecord.delete_all

    log_successful_identification
    log_new_domestic_start
    log_new_overseas_start
    log_new_domestic_complete
    log_new_domestic_ar_complete
    log_new_overseas_complete
    log_update_discarded_start
    log_update_domestic_form_complete
    log_update_domestic_ar_complete
    log_update_domestic_ar_form_complete
    log_update_overseas_complete

    Rake::Task["va:export_log"].execute
  end

  private

  def log_successful_identification
    reg = domestic_reg
    loc = reg.vvr_county_or_city
    LogRecord.identify(reg, loc)
  end

  def log_new_domestic_start
    LogRecord.start_new(FactoryGirl.create(:registration, :residential_voter))
  end

  def log_new_overseas_start
    LogRecord.start_new(FactoryGirl.create(:registration, :overseas))
  end

  def log_new_domestic_complete
    reg = FactoryGirl.create(:registration, :residential_voter)
    sr = LogRecord.start_new(reg)
    LogRecord.complete_new(reg, sr.id)
  end

  def log_new_domestic_ar_complete
    reg = FactoryGirl.create(:registration, :residential_voter, requesting_absentee: '1')
    sr = LogRecord.start_new(reg)
    LogRecord.complete_new(reg, sr.id)
  end

  def log_new_overseas_complete
    reg = FactoryGirl.create(:registration, :overseas)
    sr = LogRecord.start_new(reg)
    LogRecord.complete_new(reg, sr.id)
  end

  def log_update_discarded_start
    LogRecord.start_update(domestic_reg)
    
    af = ActiveForm.create(voter_id: domestic_reg.voter_id, form: "VoterRegistration", jurisdiction: domestic_reg.vvr_county_or_city)
    LogRecord.discard(af)
  end
  
  def log_update_domestic_form_complete
    reg = FactoryGirl.create(:existing_residential_voter, voter_id: 'update_domestic_form_complete')
    sr = LogRecord.start_update(reg)

    reg.vvr_street_number = '123123'
    LogRecord.complete_update(reg, sr.id)
  end

  def log_update_domestic_ar_complete
    reg = FactoryGirl.create(:existing_residential_voter, voter_id: 'update_domestic_ar_complete')
    sr = LogRecord.start_update(reg)

    reg.requesting_absentee = '1'
    LogRecord.complete_update(reg, sr.id)
  end

  def log_update_domestic_ar_form_complete
    reg = FactoryGirl.create(:existing_residential_voter, voter_id: 'update_domestic_ar_form_complete')
    sr = LogRecord.start_update(reg)

    reg.vvr_street_number = '123123'
    reg.requesting_absentee = '1'
    LogRecord.complete_update(reg, sr.id)
  end

  def log_update_overseas_complete
    reg = FactoryGirl.create(:existing_overseas_voter, voter_id: 'update_overseas_complete')
    sr = LogRecord.start_update(reg)
    LogRecord.complete_update(reg, sr.id)
  end

  # domestic record
  def domestic_reg
    @dr ||= FactoryGirl.create(:existing_residential_voter)
  end

  # overseas record
  def overseas_reg
    FactoryGirl.create(:existing_overseas_voter)
  end

end
