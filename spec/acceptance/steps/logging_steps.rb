steps_for :logging do

  step 'the record lookup is successful' do
    lookup_record
  end

  step 'voter begins changing their record' do
    start_editing_record
  end

  step 'voter begins filling new form' do
    visit new_registration_path
  end

  step 'voter submits the domestic form update' do
    start_editing_record
    fill_missing_data
  end

  step 'voter submits the domestic absentee request' do
    start_editing_record
    fill_missing_data :with_absentee_request
  end

  step 'voter submits the new form' do
    seed_localities
    start_new_record
    fill_domestic_data
  end

  step 'an identify record should be created' do
    r = LogRecord.last

    r.action.should       == 'identify'
    r.voter_id.should     == '600000000'
    r.form.should         be_nil
    r.form_note.should    be_nil
    r.jurisdiction.should == 'NORFOLK CITY'
    r.notes.should        == 'onlineVoterReg'
  end

  step 'an update start record should be created' do
    r = LogRecord.last

    r.action.should       == 'start'
    r.voter_id.should     == '600000000'
    r.form.should         == 'VoterRegistration'
    r.form_note.should    == 'onlineGenerated'
    r.jurisdiction.should == 'NORFOLK CITY'
    r.notes.should        be_blank
  end

  step 'a creation start record should be created' do
    r = LogRecord.last

    r.action.should       == 'start'
    r.voter_id.should     be_blank
    r.form.should         == 'VoterRegistration'
    r.form_note.should    == 'onlineGenerated'
    r.jurisdiction.should be_blank
    r.notes.should        be_blank
  end

  step 'an update completion record should be created' do
    r = LogRecord.last

    r.action.should       == 'complete'
    r.voter_id.should     == '600000000'
    r.form.should         == 'VoterRecordUpdate'
    r.form_note.should    == 'onlineGenerated'
    r.jurisdiction.should == 'NORFOLK CITY'
    r.notes.should        be_blank
  end

  step 'a new registration completion record should be created' do
    r = LogRecord.last

    r.action.should       == 'complete'
    r.voter_id.should     be_blank
    r.form.should         == 'VoterRecordUpdate'
    r.form_note.should    == 'onlineGenerated'
    r.jurisdiction.should == 'FAIRFAX CITY'
    r.notes.should        be_blank
  end

  step 'an additional start / complete record should be created' do
    rs = LogRecord.where(voter_id: '600000000', form: 'VoterRecordUpdateAbsenteeRequest').order('id').all
    rs.count.should == 2

    r = rs.first
    r.action.should       == 'start'
    r.form_note.should    == 'onlineGenerated'
    r.jurisdiction.should == 'NORFOLK CITY'
    r.notes.should        be_blank

    r = rs.last
    r.action.should       == 'complete'
    r.form_note.should    == 'onlineGenerated'
    r.jurisdiction.should == 'NORFOLK CITY'
    r.notes.should        be_blank
  end

  private

  def seed_localities
    Office.create(locality: "NORFOLK CITY", address: "PO Box 1531\nNorfolk, VA 23501-1531\n(757) 664 - 4353")
    Office.create(locality: "FAIRFAX CITY", address: "Sisson House\n10455 Armstrong St\nFairfax, VA 22030-3640\n(703) 385 - 7890")
  end

  def lookup_record
    seed_localities

    visit search_path

    choose  'Use Voter ID'
    fill_in 'Voter ID', with: '600000000'
    select  'NORFOLK CITY', from: 'locality_vid'
    check   'swear'

    VCR.use_cassette("logging_search") do
      click_button 'Next'
    end
  end

  def start_editing_record
    lookup_record
    click_link 'edit_registration'
  end

  def start_new_record
    visit new_registration_path
  end

  def fill_missing_data(option = nil)
    # Addresses
    select 'NORFOLK CITY', from: 'County or city'
    within '.existing_registration' do
      choose 'No'
    end
    click_button 'Next'

    # Options
    if option == :with_absentee_request
      check  'registration_requesting_absentee'
      select '2019 November General', from: 'registration_rab_election'
      select 'My pregnancy', from: 'registration_ab_reason'
    end
    click_button 'Next'

    # Summary
    click_button 'Next'

    sign_oath
  end

  def sign_oath
    check 'registration_information_correct'
    check 'registration_privacy_agree'
    click_button 'Next'
  end

  def fill_domestic_data
    # Eligibility
    check  'I am a citizen of the United States of America.'
    check  'I will be at least 18 years of age on or before the next Election Day.'
    choose 'registration_rights_revoked_0'
    click_button 'Next'

    # Identity
    fill_in 'Last name', with: 'Smith'
    fill_in_date 'Date of birth', with: 30.years.ago
    select  'Male', from: 'Gender'
    fill_in 'Social Security Number', with: '123123123'
    click_button 'Next'

    # Addresses
    fill_in 'Street number', with: '1'
    fill_in 'Street name', with: 'Name'
    select  'ST', from: 'Street type'
    select  'FAIRFAX CITY', from: 'County or city'
    fill_in 'Zip code', with: '12312'
    choose  'registration_has_existing_reg_0'
    click_button 'Next'

    # Opions
    click_button 'Next'

    # Review
    click_button 'Next'

    sign_oath
  end

  def fill_in_date(name, options)
    date = options[:with]
    within find_field(name).parent do
      find('select[name*="2i"]').select(date.strftime('%B'))
      find('select[name*="3i"]').select(date.day.to_s)
      find('select[name*="1i"]').select(date.year.to_s)
    end
  end

end
