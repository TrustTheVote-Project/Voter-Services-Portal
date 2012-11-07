steps_for :registration_form do

  step 'I start new registration' do
    visit new_registration_path
  end

  step 'choose rural registration address' do
    # fill eligibility page
    check   'registration_citizen'
    check   'registration_old_enough'
    choose  'registration_residence_in'
    choose  'registration_rights_revoked_0'
    click_button 'Next'

    # fill identity page
    fill_in 'registration_last_name', with: 'Last name'
    select  'January', from: 'registration_dob_2i_'
    select  '1', from: 'registration_dob_3i_'
    select  '1995', from: 'registration_dob_1i_'
    select  'Male', from: 'registration_gender'
    fill_in 'registration_ssn', with: '123123123'
    click_button 'Next'

    check   'registration_vvr_is_rural'
  end

  step 'mailing address same as registration selector should disappear' do
    find('.section#mailing input#registration_ma_is_same_0').should_not be_visible
  end

  step 'mailing address form should be visible' do
    find('.section#mailing .address-field').should be_visible
  end

  step 'unselect rural registration address' do
    uncheck 'registration_vvr_is_rural'
  end

  step 'mailing address selector should appear' do
    find('.section#mailing input#registration_ma_is_same_0').should be_visible
  end

  step 'mailing address should be marked as not being the same as registration address' do
    find('.section#mailing input#registration_ma_is_same_0').should be_checked
  end
end
