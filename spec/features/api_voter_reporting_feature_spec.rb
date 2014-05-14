require 'spec_helper'

feature 'Voter reporting' do

  let(:qv) { lookup_call }

  scenario 'Report arrival and completion' do
    # lookup and get polling locations list
    json  = lookup_call
    token = json['token']
    pl    = json['polling_locations'].first

    # report arrival
    arrival_call token, pl['uuid']
    expect(page.status_code).to eq 200

    # report completion
    completion_call token, pl['uuid']
    expect(page.status_code).to eq 200
  end


  scenario 'Duplicate lookup should return the same token' do
    json = lookup_call
    first_token = json['token']

    json = lookup_call
    expect(first_token).to eq json['token']
  end


  scenario 'Recording completion before arrival' do
    res = completion_call
    expect(page.status_code).to eq 401
    expect(res['error']).to eq "Can't record completion before the arrival"
  end


  scenario 'Recording completion twice' do
    arrival_call
    completion_call

    res = completion_call
    expect(page.status_code).to eq 401
    expect(res['error']).to eq "Can't record completion more than once"
  end


  scenario 'Recording arrival after completion' do
    arrival_call
    completion_call

    res = arrival_call
    expect(page.status_code).to eq 401
    expect(res['error']).to eq "Can't report arrival after completion"
  end


  scenario 'Reporting wait time info for never used polling location' do
    json = wait_time_info
    expect(json['last_completion']).to eq nil
    expect(json['waiting_count']).to eq 0
    expect(json['completed_count']).to eq 0
  end

  scenario 'Reporting waiting in line' do
    arrival_call
    json = wait_time_info
    expect(json['last_completion']).to eq nil
    expect(json['waiting_count']).to eq 1
    expect(json['completed_count']).to eq 0
  end

  scenario 'Reporting completed' do
    Timecop.travel(5.minutes.ago) do
      arrival_call
    end

    Timecop.freeze do
      completion_call
      json = wait_time_info
      expect(json['last_completion']).to eq({ waited: 5.minutes, completed_at: Time.now.utc.strftime('%Y-%m-%d %H:%M:%S') })
      expect(json['waiting_count']).to eq 1
      expect(json['completed_count']).to eq 0
    end
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

  def arrival_call(token = nil, polling_location_id = nil)
    token, polling_location_id = ensure_params(token, polling_location_id)
    json_call 'report_arrive', token: token, polling_location_id: polling_location_id
  end

  def completion_call(token = nil, polling_location_id = nil)
    token, polling_location_id = ensure_params(token, polling_location_id)
    json_call 'report_complete', token: token, polling_location_id: polling_location_id
  end

  def wait_time_info
    token = qv['token']
    polling_location_id = qv['polling_locations'].first['uuid']

    json_call 'wait_time_info', token: token, polling_location_id: polling_location_id
  end

  def ensure_params(token, polling_location_id)
    if token.nil? || polling_location_id.nil?
      token = qv['token']
      polling_location_id = qv['polling_locations'].first['uuid']
    end

    return [ token, polling_location_id ]
  end

end
