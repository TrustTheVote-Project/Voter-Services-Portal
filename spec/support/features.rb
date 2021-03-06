def seed_offices
  Office.delete_all
  Office.create!(locality: "ALEXANDRIA CITY", addressline: "Some address")
  Office.create!(locality: "NORFOLK CITY", addressline: "Some address")
end

def fill_eligibility_page(options = {})
  within('.citizen') { choose options[:citizen] || 'Yes' }
  within('.old_enough') { choose options[:old_enough] || 'Yes' }

  unless options[:skip_rights]
    within('.rights_revoked') do
      if AppConfig['enable_expanded_felony_mental_eligibility']
        choose 'registration_rights_felony_0'
        choose 'registration_rights_mental_0'
      else
        choose 'No'
      end
    end
  end

  click_button 'Next'
end

def fill_identity_page(options = {})
  fill_in "Given name", with: "Jack"
  fill_in "Surname (Last Name)", with: "Smith"
  select  "Male", from: "Gender"

  if AppConfig['require_middle_name']
    fill_in "Full middle", with: "Aaron"
  end

  if AppConfig['require_name_suffix']
    select "Jr", from: "Suffix"
  end

  unless options[:skip_dob]
    select  "January",  from: "registration_dob_2i_"
    select  "1",        from: "registration_dob_3i_"
    select  "1996",     from: "registration_dob_1i_"
  end

  fill_in "Social Security Number", with: "123123123"
  if options[:dmv_id]
    fill_in I18n.t('dmvid'), with: options[:dmv_id]
  else
    check I18n.t("eligibility.dmvid.dont_have")
  end

  click_button "Next"
end

def fill_address_page
  fill_in I18n.t('addresses.address'), with: "12 High St"
  fill_in I18n.t('addresses.zip5'), with: "12345"
  select  "ALEXANDRIA CITY", from: I18n.t('addresses.county_or_city')
  fill_in I18n.t('addresses.city_town'), with: "Alexandria"
  choose  "registration_pr_status_0"
  click_button "Next"
end

def skip_options_page
  expect(page).to have_text "Optional Questions"
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

  check "registration_information_correct"
  click_button "Next"
end
