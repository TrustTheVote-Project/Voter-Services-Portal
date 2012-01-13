steps_for :filling_personal_id_form do

  step 'I am on the front page' do
    visit root_path
  end

  step '(I) submit the form' do
    click_button 'Find My Voter Records'
  end

  step 'I should be warned of incomplete form' do
    page.should have_content "incomplete"
  end

  step 'I fill some of required fields' do
    fill_in 'First name', with: 'Jack'
  end

  step 'I fill existing person voter id' do
    stub_registration
    fill_in 'Voter ID', with: 'existing'
  end

  step 'I fill unknown person voter id' do
    fill_in 'Voter ID', with: 'unknown'
  end

  step 'I fill required fields of existing person' do
    stub_registration
    fill_required_fields
  end

  step 'I fill required fields of unknown person' do
    fill_required_fields
  end

  def fill_required_fields
    fill_in 'First name', with: 'Jack'
    fill_in 'Last name',  with: 'Smith'
    select  'York County', from: 'Locality'
    fill_in 'Last 4 digits of SSN', with: '1111'
  end

  def stub_registration
    reg = Factory.build(:registration)
    RegistrationSearch.should_receive(:perform).and_return(reg)
    return reg
  end

end

