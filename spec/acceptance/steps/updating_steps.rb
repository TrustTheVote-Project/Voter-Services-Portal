steps_for :updating do

  step 'I look up :kind record' do |kind|
    visit search_path

    if kind == 'residential voter'
      voter_id = '123123123'
    elsif kind == 'domestic absentee'
      voter_id = '333222111'
    else
      voter_id = '111222333'
    end

    fill_in "search_query_first_name", with: 'First'
    fill_in "search_query_last_name",  with: 'Last'
    select  "1",       from: "search_query_dob_3i_"
    select  "January", from: "search_query_dob_2i_"
    select  "1995",    from: "search_query_dob_1i_"
    select  "ACCOMACK COUNTY", from: "search_query_locality"

    fill_in "search_query_voter_id", with: voter_id
    check   "swear"

    click_button "Next"
  end

  step 'I should see view and update page' do
    page.should have_content("View & Update")
  end

  step 'I should see :status status selected' do |status|
    page.should have_checked_field status
  end

  step 'I proceed without making changes' do
    step 'I proceed'
    step 'I should see the addresses page'
    step 'I proceed'
    step 'I should see the options page'
    step 'I proceed'
    step 'I should see the confirmation page'
    step 'I proceed'
    step 'I should see the oath page'
    step 'I check boxes on the oath page'
    step 'I proceed'
  end

  step 'I proceed' do
    el = first(:css, ".btn.next", {})
    el.click
  end

  step 'I should see the addresses page' do
    should_be_visible "Registration address"
    should_be_visible "Mailing address"
  end

  step 'I should see the options page' do
    should_be_visible "Options"
  end

  step 'I should see the confirmation page' do
    should_be_visible "Confirm"
  end

  step 'I should see the oath page' do
    should_be_visible "Oath"
  end

  step 'I check boxes on the oath page' do
    check "registration_information_correct"
    check "registration_privacy_agree"
  end

  step 'I should see the download page' do
    page.should have_content "Download"
  end

  step 'the next button should be disabled' do
    page.should have_css ".btn.next.disabled"
  end

  step 'change status to domestic absentee' do
    choose  "Domestic Absentee Voter"
    step    "I proceed"

    step    "I should see the addresses page"
    step    "I proceed"

    step    "I should see the options page"
    select  Dictionaries::ELECTIONS.to_a.first[1], from: "registration_rab_election"
    select  "My pregnancy", from: "registration_ab_reason"
    step    "I proceed"
  end

  step 'change status to overseas absentee' do
    choose  "Overseas/Military Absentee Voter"
    step    "I proceed"

    step    "I should see the addresses page"
    choose  "My Virginia residence is still available to me"

    choose  "I prefer that voting materials be sent to me at an APO/DPO/FPO address"
    fill_in "registration_apo_address", with: "Sample address"
    fill_in "registration_apo_zip5", with: "12345"
    step   "I proceed"

    step    "I should see the options page"
    choose  "Active Duty Merchant Marine or Armed Forces"
    fill_in "registration_service_id", with: "service-id"
    fill_in "registration_rank", with: "rank"
    step    "I proceed"
  end

  step 'change status to residential voter' do
    choose  "Virginia Residential Voter"
    step    "I proceed"

    step    "I should see the addresses page"
    step    "I proceed"

    step    "I should see the options page"
    step    "I proceed"
  end

  step 'I should see :new_status on confirm page' do |new_status|
    step "I should see the confirmation page"
    page.should have_content new_status
  end

  step 'should be able to submit the update' do
    step "I proceed"
    step 'I should see the oath page'
    step 'I check boxes on the oath page'
    step 'I proceed'
    step 'I should see the download page'
  end

  private

  def should_be_visible(label)
    first("h3", text: label).should be_visible
  end

end
