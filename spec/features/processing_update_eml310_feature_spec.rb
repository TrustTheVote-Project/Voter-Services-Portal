require 'spec_helper'

feature 'Processing update EML310 submission', :js do

  before do
    Office.create!(locality: "NORFOLK CITY", address: "Some address")
  end

  describe 'Updates' do
    scenario 'Sumission errors out' do
      SubmitEml310.should_receive(:submit).and_raise(SubmitEml310::SubmissionError)
      submit_record_update
      expect(page).to have_text "Download"
    end

    scenario 'Submission succeeds' do
      SubmitEml310.should_receive(:submit_update).and_return(true)
      submit_record_update
      expect(page).to have_text "Download"
    end
  end

  describe 'New registrations' do
    before { seed_offices }

    scenario 'Submission errors out' do
      SubmitEml310.should_receive(:submit).and_raise(SubmitEml310::SubmissionError)
      submit_new_record
      expect(page).to have_text "Download"
      expect(page).to have_text "TBD 310 error"
    end

    scenario 'Submission succeeds' do
      SubmitEml310.should_receive(:submit_new).and_return({ success: true, voter_id: '123456789' })
      submit_new_record
      expect(page).to have_text "Download"
      expect(page).not_to have_text "TBD 310 error"
    end

    scenario 'DMV included, successful submission' do
      SubmitEml310.should_receive(:submit_new).and_return({ success: true, voter_id: '123456789' })
      submit_new_record dmv_id: "1234567890"
      expect(page).not_to have_text "Download"
      expect(page).to have_text "TBD online submit -- voter ID: 123456789"
    end
  end

  private

  def submit_record_update
    lookup_domestic_record
    skip_and_confirm
  end

  def lookup_domestic_record
    VCR.use_cassette("lookup_for_update_600000000") do
      visit   "/search"
      choose  "Use Voter ID"
      fill_in "Voter ID", with: "600000000"
      select  "NORFOLK CITY", from: "Locality"
      select  "January", from: "search_query_dob_2i_"
      select  "1", from: "search_query_dob_3i_"
      select  "1996", from: "search_query_dob_1i_"
      check   "swear"
      click_button "Next"
    end
  end

  def skip_and_confirm
    click_link   'Next' # start editing
    click_button 'Next' # skip address updates
    click_button 'Next' # skip options
    click_button 'Next' # confirm

    fill_in "registration_ssn4", with: "1234"
    check   "Registration Statement"
    check   "I have read and agree with the terms of the Privacy Act Notice."
    click_button 'Next' # sign oath
  end

  def submit_new_record(options = {})
    visit '/register/residential'
    fill_eligibility_page options
    fill_identity_page
    fill_address_page
    skip_options_page
    confirm
    sign_oath
  end
end
