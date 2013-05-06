require 'spec_helper'

describe SubmitEml310 do

  let(:reg) { FactoryGirl.create(:registration) }
  let(:res) { stub }

  before do
    SubmitEml310.stub(submission_url: 'http://localhost/')
  end

  it 'should report failure to submit' do
    ErrorLogRecord.should_receive(:log).with("Submit EML310", { error: "Failed to submit", response: res })
    Net::HTTP.should_receive(:start).and_return(res)
    expect {
      SubmitEml310.submit_new(reg)
    }.to raise_error SubmitEml310::SubmissionError
  end

  it 'should submit' do
    SubmitEml310.should_receive(:successful_response?).with(res).and_return(true)
    Net::HTTP.should_receive(:start).and_return(res)
    SubmitEml310.submit_new(reg).should == { success: true, voter_id: '123456789' }
  end

  describe 'easter eggs' do
    before do
      reg.last_name = "faileml310"
      SubmitEml310.should_not_receive(:send_request)
    end

    it 'should fail update when last name is "faileml310"' do
      SubmitEml310.submit_update(reg)
    end

    it 'should fail new reg when last name is "faileml310"' do
      expect { SubmitEml310.submit_new(reg) }.to raise_error SubmitEml310::SubmissionError
    end
  end
end
