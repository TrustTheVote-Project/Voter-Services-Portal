step 'I should see :message' do |msg|
  page.should have_content msg
end
