require 'spec_helper'

describe SubmitEml310 do

  let(:reg) { FactoryGirl.create(:registration) }
  let(:res) { stub }

  it 'should not schedule if submission URL is not present' do
    SubmitEml310.should_receive(:submission_url).and_return('')
    SubmitEml310.should_not_receive(:perform_async)
    SubmitEml310.schedule(stub)
  end

  it 'should report missing registration' do
    ErrorLogRecord.should_receive(:log).with("Submit EML310", { error: "Record not found", id: 0 })
    SubmitEml310.new.perform(0)
  end

  it 'should report failure to submit' do
    ErrorLogRecord.should_receive(:log).with("Submit EML310", { error: "Failed to submit", response: res })
    Net::HTTP.should_receive(:start).and_return(res)
    SubmitEml310.new.perform(reg.id)
  end

  it 'should submit' do
    s = SubmitEml310.new
    s.should_receive(:successful_response?).with(res).and_return(true)
    Net::HTTP.should_receive(:start).and_return(res)
    s.perform(reg.id)
  end

end
