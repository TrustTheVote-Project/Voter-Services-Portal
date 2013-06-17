steps_for :registration_form do

  step 'I start new registration' do
    visit new_registration_path
  end

  step 'choose rural registration address' do
    fill_eligibility_page
    fill_identity_page

    check   'registration_vvr_is_rural'
  end

  step 'mailing address same as registration selector should disappear' do
    page.should_not have_selector '.section#address input#registration_ma_is_different'
  end

  step 'mailing address form should be visible' do
    page.should have_selector '.section#mailing .address-field'
  end

  step 'unselect rural registration address' do
    uncheck 'registration_vvr_is_rural'
  end

  step 'mailing address selector should appear' do
    find('.section#address input#registration_ma_is_different').should be_visible
  end

  step 'mailing address should be marked as not being the same as registration address' do
    find('.section#address input#registration_ma_is_different').should be_checked
  end
end
