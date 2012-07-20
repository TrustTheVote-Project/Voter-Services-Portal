steps_for :requesting_absentee do

  step 'keep the status' do
    step 'I proceed'
  end

  step 'choose residential voter status option' do
   choose 'Residential Voter'
   step 'I proceed'
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
