require 'spec_helper'

describe SubmitEml310 do

  let(:reg) { FactoryGirl.create(:registration) }
  let(:res) { stub(code: '200', body: 'queued') }

  it 'should try updating if new fails with already registered' do
    Net::HTTP.any_instance.should_receive(:start).and_return(stub(code: 400, body: 'already registered'))
    SubmitEml310.should_receive(:submit_update).with(reg)
    SubmitEml310.submit_new(reg)
  end

  it 'should report failure to submit' do
    Net::HTTP.any_instance.should_receive(:start).and_return(stub(code: '400', body: 'Error'))
    expect {
      SubmitEml310.submit_new(reg)
    }.to raise_error SubmitEml310::SubmissionError
  end

  it 'should submit' do
    SubmitEml310.should_receive(:successful_response?).with(res).and_return(true)
    Net::HTTP.any_instance.should_receive(:start).and_return(res)
    SubmitEml310.submit_new(reg).should be_true
  end

end
