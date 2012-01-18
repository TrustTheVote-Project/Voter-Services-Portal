steps_for :unregistered_options do

  use_steps :personal_id_form

  step 'I submit unknown registration details' do
    fill_in 'Voter ID', with: 'unknown'
    submit_button.click
  end

  step 'be presented with options' do
    page.should have_link 'Retry identification'
    page.should have_link 'Register in VA'
    page.should have_link 'Register outside VA'
  end

end
