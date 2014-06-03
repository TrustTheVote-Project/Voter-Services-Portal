require 'spec_helper'

feature 'Voter reporting' do

  let(:vid) { '600000008' }

  let(:qv) { lookup_call }

  scenario 'Report arrival and completion' do
    # lookup and get polling locations list
    json  = lookup_call
    pl    = json['polling_locations'].first

    # report arrival
    arrival_call pl['uuid']
    expect(page.status_code).to eq 200

    # report completion
    completion_call pl['uuid']
    expect(page.status_code).to eq 200
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
      expect(json['last_completion']).to eq({ 'waited' => 5.minutes, 'completed_at' => Time.now.utc.strftime('%Y-%m-%d %H:%M:%S') })
      expect(json['waiting_count']).to eq 0
      expect(json['completed_count']).to eq 1
    end
  end

  private

  def json_call(call, params = {})
    visit "/api/v1/#{call}?#{params.to_query}"
    return JSON.parse(page.body)
  end

  def lookup_call
    json = nil

    VCR.use_cassette("vid_#{vid}") do
      json = json_call("PollingLocation", q: user_data_json(vid))
    end

    json
  end

  def user_data_json(vid)
    { "eml" =>
      { "SchemaVersion" => "7.0",
        "Id" => "310",
        "emlheader" => { "TransactionId" => 310 },
        "VoterRegistration" => {
          "Voter" => {
            "VoterIdentification" => {
              "ElectoralAddress" => {
                "PostalAddress" => {
                  "Locality" => "TAZEWELL COUNTY"
                }
              },

              "VoterPhysicalID" => {
                "VoterPhysicalID-IdType" => "VID",
                "VoterPhysicalID-value" => vid
              },

              "DateOfBirth" => "2013-06-25",
              "CheckBox" => {
                "CheckBox-Type" => "IDbyVIDwLocalityDOB",
                "CheckBox-value" => "yes"
              }
            }
          }
        }
      }
    }.to_json
  end

  def arrival_call(polling_location_id = nil)
    polling_location_id = ensure_params(polling_location_id)
    VCR.use_cassette("vid_#{vid}") do
      json_call 'ReportArrive', q: user_data_json(vid), polling_location_id: polling_location_id
    end
  end

  def completion_call(polling_location_id = nil)
    polling_location_id = ensure_params(polling_location_id)
    VCR.use_cassette("vid_#{vid}") do
      json_call 'ReportComplete', q: user_data_json(vid), polling_location_id: polling_location_id
    end
  end

  def wait_time_info
    token = qv['token']
    polling_location_id = qv['polling_locations'].first['uuid']

    VCR.use_cassette("vid_#{vid}") do
      json_call 'WaitTimeInfo', q: user_data_json(vid), polling_location_id: polling_location_id
    end
  end

  def ensure_params(polling_location_id)
    if polling_location_id.nil?
      polling_location_id = qv['polling_locations'].first['uuid']
    end

    return polling_location_id
  end

end
