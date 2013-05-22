require 'spec_helper'

feature 'Mailing address', :js do

  scenario 'After choosing rural reg address' do
    get_to_address_page

    check "Rural address or homeless? Please check the box and describe where you reside."

    cb = find("#registration_ma_is_different[type=checkbox]")
    cb.should be_checked
    cb.should be_disabled

    find_field("registration_ma_address").should be_visible
  end

  scenario 'after deselecting rural reg address' do
    get_to_address_page

    check "Rural address or homeless? Please check the box and describe where you reside."
    uncheck "Rural address or homeless? Please check the box and describe where you reside."

    cb = find("#registration_ma_is_different[type=checkbox]")
    cb.should be_checked
    cb.should_not be_disabled

    find_field("registration_ma_address").should be_visible
  end

  def get_to_address_page
    visit '/register/residential'

    fill_eligibility_page
    fill_identity_page
  end

end
