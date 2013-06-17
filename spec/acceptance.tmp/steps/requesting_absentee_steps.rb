steps_for :requesting_absentee do

  step 'keep the status' do
    step 'I proceed'
  end

  step 'choose residential voter status option' do
   choose 'Residential Voter'
   step 'I proceed'
  end

  step 'fill in missing overseas record address details' do
    choose 'My Virginia residence is still available to me'
    choose "I prefer that voting materials be sent to me at a different non-U.S address"
    fill_in "Address", with: '123 High St'
    fill_in "City or Town", with: 'Exampleville'
    fill_in "State or Province", with: 'Springfield'
    fill_in "Postal Code", with: '1234'
    fill_in "Country", with: 'Australia'
  end

  step 'proceed to options page' do
    step 'I proceed'
  end

  step 'I should see unchecked absentee request checkbox' do
    e = find(:css, "input#registration_requesting_absentee[type='checkbox']")
    e.should_not be_checked
  end

  step 'I should see read-only checked absentee request checkbox' do
    e = find(:css, "input#registration_requesting_absentee[type='checkbox'][disabled]")
    e.should be_checked
  end
end
