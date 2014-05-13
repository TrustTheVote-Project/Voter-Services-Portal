require 'spec_helper'

feature 'Looking up records' do

  scenario 'Entering search' do
    visit '/front'
    click_on 'Update or View Voter Record'

    expect(page).to have_text 'Identity'
    find_field('Use SSN4').should be_checked
  end

  scenario 'Successful search' do
    AppConfig['show_privacy_act_page'] = true

    fill_search_page '600000000'
    expect(page).to have_text 'Voter Information'

    click_link "Update Your Voter Information"

    expect(page).to have_text 'Privacy Act Notice'
    check 'I have read the terms of the Privacy Act Notice.'
  end

  scenario 'Failed search' do
    fill_search_page '600000001'
    expect(page).to have_text 'Record Not Found'
  end

  private

  # enter and fill search page
  def fill_search_page(voter_id)
    seed_offices

    visit '/search'

    choose "Use Voter ID"
    within "#vid" do
      fill_in "Voter ID", with: voter_id
      select  "NORFOLK CITY", from: "Locality"
      select  "January", from: "search_query_dob_2i_"
      select  "1", from: "search_query_dob_3i_"
      select  "1996", from: "search_query_dob_1i_"
    end

    VCR.use_cassette "search_#{voter_id}" do
      click_on 'Next'
    end
  end

end
