def seed_offices
  Office.create!(locality: "ALEXANDRIA CITY", address: "Some address")
end

def fill_eligibility_page(options = {})
  within('.citizen') { choose options[:citizen] || 'Yes' }
  within('.rights_revoked') { choose 'No' }
  select  "January",  from: "registration_dob_2i_"
  select  "1",        from: "registration_dob_3i_"
  select  "1996",     from: "registration_dob_1i_"
  fill_in "Social Security Number", with: "123123123"
  if options[:dmv_id]
    fill_in I18n.t('eligibility.dmvid.title'), with: options[:dmv_id]
  end

  click_button 'Next'
end

def fill_identity_page
  fill_in "First name", with: "Jack"
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
  if page.has_selector? '#registration_ssn'
    fill_in 'Social Security Number', with: '123456789'
  end

  check "Registration Statement"
  check "I have read and agree with the terms of the Privacy Act Notice."
  click_button "Next"
end
