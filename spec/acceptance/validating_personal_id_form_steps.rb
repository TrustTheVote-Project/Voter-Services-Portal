steps_for :validating_personal_id_form do

  use_steps :personal_id_form

  step "submit button should be/become :state" do |state|
    submit_button['disabled'].should == (state == 'enabled' ? 'false' : 'true')
  end

  step "I enter Voter ID" do
    fill_in "Voter ID", :with => "valid voter id"
  end

end
