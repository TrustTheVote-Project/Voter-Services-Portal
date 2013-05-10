require 'spec_helper'

describe SubmitEml310 do

  let(:reg) { FactoryGirl.create(:registration) }
  let(:res) { stub }

  before do
    SubmitEml310.stub(submission_url: 'http://localhost/')
  end

  it 'should report failure to submit' do
    Net::HTTP.should_receive(:start).and_return(res)
    expect {
      SubmitEml310.submit_new(reg)
    }.to raise_error SubmitEml310::SubmissionError
  end

  it 'should submit' do
    SubmitEml310.should_receive(:successful_response?).with(res).and_return(true)
    Net::HTTP.should_receive(:start).and_return(res)
    SubmitEml310.submit_new(reg).should be_true
  end


  describe 'easter eggs' do
    it 'should fail update when last name is "faileml310"' do
      reg.last_name = "faileml310"
      SubmitEml310.should_not_receive(:send_request)
      expect { SubmitEml310.submit_update(reg) }.to raise_error SubmitEml310::SubmissionError
    end

    it 'should not submit records with non-9-digit DMVID' do
      reg.dmv_id = "1234567890"
      SubmitEml310.submit_update(reg).should be_false
    end

    it 'should submit records with 9-digit DMVID' do
      reg.dmv_id = "123456789"
      SubmitEml310.submit_update(reg).should be_true
    end

    it 'should fail new reg when last name is "faileml310"' do
      reg.last_name = "faileml310"
      SubmitEml310.should_not_receive(:send_request)
      expect { SubmitEml310.submit_new(reg) }.to raise_error SubmitEml310::SubmissionError
    end

    it 'should not submit records with non-9-digit DMVID' do
      reg.dmv_id = "1234567890"
      SubmitEml310.submit_new(reg).should be_false
    end

    it 'should submit records with 9-digit DMVID' do
      reg.dmv_id = "123456789"
      SubmitEml310.submit_new(reg).should be_true
    end
  end
end
