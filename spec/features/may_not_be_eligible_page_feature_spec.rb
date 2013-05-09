require 'spec_helper'

feature 'Showing may not be eligible page', :js do

  scenario 'Ineligible' do
    visit '/register/residential'

    fill_eligibility_page(citizen: 'No')

    expect(page).to have_text "you may not be eligible"

    # going back should bring eligibility page
    click_button 'Back'
    expect(page).to have_text "Eligibility"

    # going forward should bring identity page
    click_button 'Next' # shows "You might not be eligible" page again
    click_button 'Next'
    expect(page).to have_text "Identity"
  end

end
