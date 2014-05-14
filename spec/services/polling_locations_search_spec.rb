require 'spec_helper'

describe PollingLocationsSearch, :focus do

  it 'should return results' do
    r = search(600000008, 'TAZEWELL COUNTY')

    expect(r).to eq [
      { name:    "NUCKOLLS HALL",
        address: "515 FAIRGROUND RD",
        city:    "N TAZEWELL",
        state:   "VA",
        zip:     "24630-0870" },
      { name:    "",
        address: "PO BOX 201",
        city:    "TAZEWELL",
        state:   "VA",
        zip:     "24651-0201",
        phone:   "2769881305" }
    ]
  end

  it 'should raise RecordNotFound if no polling locations' do
    expect(PollingLocationsSearch).to receive(:parse).and_return([])

    expect {
      search(600000008, 'TAZEWELL COUNTY')
    }.to raise_error PollingLocationsSearch::RecordNotFound
  end

  private

  def search(n, loc)
    VCR.use_cassette("vid_#{n}") do
      PollingLocationsSearch.perform(query_for(n, loc))
    end
  end

  def query_for(n, loc)
    double('SearchQuery', voter_id: n, locality: loc, first_name: 'Mark', last_name: 'Smith', dob: Date.parse('2013-06-25'))
  end

end
