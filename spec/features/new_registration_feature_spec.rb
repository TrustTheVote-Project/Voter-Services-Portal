require 'spec_helper'

feature 'New registration', :js do

  before { seed_offices }

  scenario 'DMV match should populate the address section' do
    visit '/register/residential'

    fill_eligibility_page dmv_id: '123456789'
    fill_identity_page

    find_field("Street number").value.should  == "123"
    find_field("Street name").value.should    == "WannaVote"
    find_field("Street type").value.should    == "DR"
    find_field("Zip code").value.should       == "12345"
    find_field("County or city").value.should == "ALEXANDRIA CITY"
    expect(page).to have_text I18n.t("dmv.address_info")
  end

  scenario 'w/ special page instead of d/l for unregistered DMV matches' do
    visit '/register/residential'

    fill_eligibility_page dmv_id: '123456789'
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath

    expect(page).not_to have_text "Download"
    expect(page).to have_text "Submit Your Application Online"
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
