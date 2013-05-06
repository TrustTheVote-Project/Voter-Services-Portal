require 'spec_helper'

feature 'New registration' do

  before do
    Office.create!(locality: "ALEXANDRIA CITY", address: "Some address")
  end

  scenario 'w/ special page instead of d/l for unregistered DMV matches', :js do
    visit '/register/residential'

    fill_eligibility_page dmv_id: '012345678'
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath

    expect(page).not_to have_text "Download"
    expect(page).to have_text "TBD text for completing online submission with no paper form needed"
  end

  scenario 'w/ d/l screen for normal records', :js do
    visit '/register/residential'

    fill_eligibility_page dmv_id: '0123456789'
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath

    expect(page).to have_text "Download"
  end

  private

  def fill_eligibility_page(options)
    check   "I am a citizen of the United States of America."
    check   "I will be at least 18 years of age on or before the next Election Day."
    choose  "No"
    select  "January",  from: "registration_dob_2i_"
    select  "1",        from: "registration_dob_3i_"
    select  "1996",     from: "registration_dob_1i_"
    fill_in "Social Security Number", with: "123123123"
    fill_in "Department of Motor Vehicles ID Number", with: options[:dmv_id]
    click_button "Next"
  end

  def fill_identity_page
    fill_in "Last name", with: "Smith"
    select  "Male", from: "Gender"
    click_button "Next"
  end

  def fill_address_page
    fill_in "Street number", with: "12"
    fill_in "Street name", with: "High"
    fill_in "Zip code", with: "12345"
    select  "ST", from: "Street type"
    select  "ALEXANDRIA CITY", from: "County or city"
    choose  "registration_has_existing_reg_0"
    click_button "Next"
  end

  def skip_options_page
    expect(page).to have_text "Options"
    click_button "Next"
  end

  def confirm
    expect(page).to have_text "Confirm"
    click_button "Next"
  end

  def sign_oath
    check "Registration Statement"
    check "I have read and agree with the terms of the Privacy Act Notice."
    click_button "Next"
  end
end
