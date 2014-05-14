require 'spec_helper'

describe SubmitEml310 do

  let(:reg) { FactoryGirl.create(:registration) }
  let(:res) { double(code: '200', body: 'queued') }

  it 'should try updating if new fails with already registered' do
    expect_any_instance_of(Net::HTTP).to receive(:start).and_return(double(code: 400, body: 'already registered'))
    expect(SubmitEml310).to receive(:submit_update).with(reg)
    SubmitEml310.submit_new(reg)
  end

  it 'should report failure to submit' do
    expect_any_instance_of(Net::HTTP).to receive(:start).and_return(double(code: '400', body: 'Error'))
    expect {
      SubmitEml310.submit_new(reg)
    }.to raise_error SubmitEml310::SubmissionError
  end

  it 'should submit' do
    expect(SubmitEml310).to receive(:successful_response?).with(res).and_return(true)
    expect_any_instance_of(Net::HTTP).to receive(:start).and_return(res)
    SubmitEml310.submit_new(reg).should be_true
  end

end
