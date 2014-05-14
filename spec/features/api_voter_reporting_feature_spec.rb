require 'spec_helper'

feature 'Voter reporting' do

  scenario 'Report arrival and completion' do
    json = json_call("lookup", a: 1, b: "abc")
  end

  def json_call(call, params = {})
    visit "/api/voter_reporting/#{call}?#{params.to_query}"
    return JSON.parse(page.body)
  end

end
