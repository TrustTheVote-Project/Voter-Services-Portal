require 'spec_helper'

feature 'Voter reporting' do

  scenario 'Report arrival and completion' do
    # lookup and get polling locations list
    json  = lookup_call
    token = json['token']
    pl    = json['polling_locations'].first

    # report arrival
    json_call("report_arrive", token: token, polling_location_id: pl['uuid'])
    expect(page.status_code).to eq 200

    # report completion
    json_call("report_complete", token: token, polling_location_id: pl['uuid'])
    expect(page.status_code).to eq 200
  end


  scenario 'Duplicate lookup should return the same token' do
    json = lookup_call
    first_token = json['token']

    json = lookup_call
    expect(first_token).to eq json['token']
  end



  private

  def json_call(call, params = {})
    visit "/api/voter_reporting/#{call}?#{params.to_query}"
    return JSON.parse(page.body)
  end

  def lookup_call
    json = nil
    vid  = '600000008'

    VCR.use_cassette("vid_#{vid}") do
      json = json_call("lookup", 'voter_id' => vid, 'locality' => 'TAZEWELL COUNTY', 'dob(1i)' => '2013', 'dob(2i)' => '6', 'dob(3i)' => '25')
    end

    json
  end

end
