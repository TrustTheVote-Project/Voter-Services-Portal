require 'spec_helper'

describe RegistrationRepository do

  let(:session) { Hash.new }
  let(:registration) { Factory.build(:registration) }

  before  { RegistrationRepository.store_registration(session, registration) }

  describe 'persisting registration' do
    specify { session[:registration_id].should == Registration.first.id }
    specify { RegistrationRepository.get_registration(session).should == registration }
  end

  describe 'removing registration' do
    before  { RegistrationRepository.remove_registration(session) }
    specify { session.should_not be_include :registration_id }
  end

end
