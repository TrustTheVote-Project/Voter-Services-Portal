steps_for :search do

  step "I enter the search page" do
    visit search_form_path
  end

  step "I should see SSN4 option preselected" do
    page.find('input#search_query_lookup_type_ssn4').should be_checked
  end

end
