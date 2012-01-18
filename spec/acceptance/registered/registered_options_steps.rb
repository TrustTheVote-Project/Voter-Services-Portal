steps_for :registered_options do

  step 'my non-absentee registration record was found' do
    reg = Factory.build(:registration)
    RegistrationRepository.stub(:get_registration).and_return(reg)
  end

  step 'I should be presented with options' do
    # Non UOCAVA voters
    page.should have_link 'Change of residence address'
    page.should have_link 'Change of mailing address'
    page.should have_link 'Change of name'
    page.should have_link 'Change of party affiliation'
    page.should have_link 'Request absentee status for next election'

    # TODO need to check the same for UOCAVA voters too
  end

end
