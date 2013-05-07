require 'spec_helper'

feature 'New registration', :js do

  before { seed_offices }

  scenario 'w/ special page instead of d/l for unregistered DMV matches' do
    visit '/register/residential'

    fill_eligibility_page dmv_id: '123456789'
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath

    expect(page).not_to have_text "Download"
    expect(page).to have_text "TBD text for completing online submission with no paper form needed"
  end

  scenario 'w/ d/l screen for normal records' do
    visit '/register/residential'

    fill_eligibility_page dmv_id: '1234567890'
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath

    expect(page).to have_text "Download"
  end

end
