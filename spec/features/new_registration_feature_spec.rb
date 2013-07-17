require 'spec_helper'

feature 'New registration', :js do

  before { seed_offices }

  scenario 'DMV match should populate the address section' do
    LookupService.stub(registration: { registered: false, dmv_match: true, address: { address_1: "123 WannaVote DR", zip5: "12345", county_or_city: "ALEXANDRIA CITY" }})
    visit '/register/residential'

    fill_eligibility_page dmv_id: '000000002'
    fill_identity_page

    find_field(I18n.t("addresses.address")).value.should        == "123 WannaVote DR"
    find_field(I18n.t("addresses.zip5")).value.should           == "12345"
    find_field(I18n.t("addresses.county_or_city")).value.should == "ALEXANDRIA CITY"
    expect(page).to have_text I18n.t("dmv.address_info")
  end

  scenario 'w/ special page instead of d/l for unregistered DMV matches' do
    LookupService.stub(registration: { registered: false, dmv_match: true })
    SubmitEml310.stub(submit_new: true)
    visit '/register/residential'

    fill_eligibility_page dmv_id: '1234567890'
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath

    expect(page).not_to have_text "Download"
    expect(page).to have_text "Submit Your Application Online"
  end

  scenario 'w/ d/l screen for normal records' do
    LookupService.stub(registration: { registered: false, dmv_match: false })
    SubmitEml310.stub(submit_new: false)
    visit '/register/residential'

    fill_eligibility_page dmv_id: '1234567890'
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath

    expect(page).to have_text "Submit Your Application"
  end

end
