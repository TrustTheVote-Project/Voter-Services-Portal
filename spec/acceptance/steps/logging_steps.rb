steps_for :logging do

  step 'record lookup is successful' do
    lookup_domestic_record
  end

  step 'started domestic registration' do
    start_domestic_registration
  end

  step 'started overseas registration' do
    start_overseas_registration
  end

  step 'started domestic update' do
    lookup_domestic_record
    click_link 'edit_registration'
  end

  step 'started overseas update' do
    lookup_overseas_record
    click_link 'edit_registration'
  end

  step ':action :form should be logged' do |action, form|
    # puts LogRecord.all.map { |l| "#{l.action} #{l.form}" }.join("\n")
    LogRecord.where(action: action, form: form).first.should be
  end

  step ':action :form should not be logged' do |action, form|
    LogRecord.where(action: action, form: form).count.should == 0
  end

  step 'completed domestic registration' do
    seed_localities
    start_domestic_registration
    fill_domestic_data
  end

  step 'completed domestic registration with absentee request' do
    seed_localities
    start_domestic_registration
    fill_domestic_data :with_absentee_request
  end

  step 'completed overseas registration' do
    seed_localities
    start_overseas_registration
    fill_overseas_data
  end

  step 'completed domestic update with only form changes' do
    update_domestic_data true, false
  end

  step 'completed domestic update with absentee request and no form changes' do
    update_domestic_data false, true
  end

  step 'completed domestic update with absentee request and form changes' do
    update_domestic_data true, true
  end

  step 'completed overseas update' do
    lookup_overseas_record
    click_link 'edit_registration'

    # Addresses
    fill_in "registration_mau_state", with: "S"
    click_button "Next"

    # Options
    choose  "Temporarily residing outside U.S."
    click_button "Next"

    # Confirm
    click_button "Next"

    sign_oath
  end

  step 'identify record should be created' do
    r = LogRecord.last

    r.action.should       == 'identify'
    r.voter_id.should     == '600000000'
    r.form.should         == 'VoterRegistration'
    r.jurisdiction.should == 'NORFOLK CITY'
  end

  private

  def seed_localities
    Office.create(locality: "NORFOLK CITY", address: "PO Box 1531\nNorfolk, VA 23501-1531\n(757) 664 - 4353")
    Office.create(locality: "FAIRFAX CITY", address: "Sisson House\n10455 Armstrong St\nFairfax, VA 22030-3640\n(703) 385 - 7890")
    Office.create(locality: "ALBEMARLE COUNTY", address: "Some address")
  end

  def lookup_domestic_record
    lookup_record '600000000', 'NORFOLK CITY'
  end

  def lookup_overseas_record
    lookup_record '600000048', 'ALBEMARLE COUNTY'
  end

  def lookup_record(vid, locality)
    seed_localities

    visit search_path

    choose  'Use Voter ID'
    within "#vid" do
      fill_in 'Voter ID', with: vid
      select  locality, from: 'locality_vid'
      select  "January",  from: "search_query_dob_2i_"
      select  "1",        from: "search_query_dob_3i_"
      select  "1996",     from: "search_query_dob_1i_"
    end
    check   'swear'

    VCR.use_cassette("logging_search_#{vid}") do
      click_button 'Next'
    end
  end

  def start_domestic_registration
    visit new_registration_path
  end

  def start_overseas_registration
    visit register_overseas_path
  end

  def sign_oath
    if page.has_selector? '#registration_ssn4'
      fill_in 'registration_ssn4', with: '1234'
    end

    check 'registration_information_correct'
    check 'registration_privacy_agree'
    click_button 'Next'
  end

  def fill_eligibility
    check  'I am a citizen of the United States of America.'
    check  'I will be at least 18 years of age on or before the next Election Day.'
    choose 'registration_rights_revoked_0'
    click_button 'Next'
  end

  def fill_identity
    fill_in 'Last name', with: 'Smith'
    fill_in_date 'Date of birth', with: 30.years.ago
    select  'Male', from: 'Gender'
    fill_in 'Social Security Number', with: '123123123'
    click_button 'Next'
  end

  def fill_registration_address
    fill_in 'Street number', with: '1'
    fill_in 'Street name', with: 'Name'
    select  'ST', from: 'Street type'
    select  'FAIRFAX CITY', from: 'County or city'
    fill_in 'Zip code', with: '12312'
  end

  def fill_overseas_data
    fill_eligibility
    fill_identity

    # Addresses
    fill_registration_address
    choose  'My Virginia residence is still available to me'
    fill_in 'registration_mau_address', with: '1 Main St'
    fill_in 'registration_mau_city', with: 'Carrum'
    fill_in 'registration_mau_state', with: 'Victoria'
    fill_in 'registration_mau_postal_code', with: '3197'
    fill_in 'registration_mau_country', with: 'Australia'
    choose  'registration_has_existing_reg_0'
    click_button 'Next'

    # Options
    choose  'Temporarily residing outside U.S.'
    click_button 'Next'

    # Confirm
    click_button 'Next'

    sign_oath
  end

  def fill_domestic_data(option = nil)
    fill_eligibility
    fill_identity

    # Addresses
    fill_registration_address
    choose  'registration_has_existing_reg_0'
    click_button 'Next'

    # Opions
    if option == :with_absentee_request
      request_absentee
    end
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

  def update_domestic_data(change_form, make_absentee_request)
    lookup_domestic_record
    click_link 'edit_registration'

    # Addresses
    if change_form
      fill_in 'Street number', with: '111'
    end
    click_button 'Next'

    # Options
    if make_absentee_request
      request_absentee
    end
    click_button 'Next'

    # Confirm
    click_button 'Next'

    sign_oath
  end

  def request_absentee
    check  'registration_requesting_absentee'

    v = find("#registration_rab_election option:nth-child(2)").text
    select v, from: 'registration_rab_election'
    select 'My pregnancy', from: 'registration_ab_reason'
  end

end
