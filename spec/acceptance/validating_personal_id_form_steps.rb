steps_for :validating_personal_id_form do

  use_steps :personal_id_form

  step "submit button should be/become :state" do |state|
    submit_button['disabled'].should == (state == 'enabled' ? 'false' : 'true')
  end

  step "(I) enter Voter ID" do
    fill_in "Voter ID", :with => "valid voter id"
  end

  step "I enter short SSN4" do
    change_value_of "Last 4 digits of SSN", :to => "12"
  end

  step "I leave :field empty" do |field|
    change_value_of field, :to => ''
  end

  step "I should see an error :msg next to :field" do |msg, field|
    within find_field(field).parent do
      find(".invalid").should have_content(msg)
    end
  end

  def change_value_of(field_name, options)
    f = find_field(field_name)
    f.set(options[:to])
    page.execute_script("$('#" + f['id'] + "').trigger('blur')")
  end

end
