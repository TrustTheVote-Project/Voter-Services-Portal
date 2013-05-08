require 'spec_helper'

feature 'Showing may not be eligible page', :js, :focus do

  scenario 'Ineligible' do
    visit '/register/residential'

    options = { citizen: 'No' }

    within('.citizen') { choose options[:citizen] || 'Yes' }
    within('.old_enough') { choose options[:old_enough] || 'Yes' }
    within('.rights_revoked') { choose 'No' }
    select  "January",  from: "registration_dob_2i_"
    select  "1",        from: "registration_dob_3i_"
    select  "1996",     from: "registration_dob_1i_"
    fill_in "Social Security Number", with: "123123123"
    if options[:dmv_id]
      fill_in "Department of Motor Vehicles ID Number", with: options[:dmv_id]
    else
      check   "I do not have a DMV ID number"
    end

    click_button 'Next'
    expect(page).to have_text "You might not be eligible"

    # going back should bring eligibility page
    click_button 'Back'
    expect(page).to have_text "Eligibility"

    # going forward should bring identity page
    click_button 'Next' # shows "You might not be eligible" page again
    click_button 'Next'
    expect(page).to have_text "Identity"
  end

  scenario 'Incomplete form data' do
  end

end
