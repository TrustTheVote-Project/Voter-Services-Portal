require 'spec_helper'

describe MyBallotElectionsController do

  describe 'show' do
    let(:reg) { stub(voter_id: "600000000") }

    before do
      controller.stub(current_registration: reg)
    end

    it 'should render election page', :vcr do
      get :show, uid: '6002FDB4-FC9C-4F36-A418-C0BDFFF2E579'
      expect(assigns(:election)[:name]).to eq "2013 November General"
      expect(page).to render_template :show
    end

    it 'should redirect to registration details if election was not found' do
      get :show, uid: 'missing'
      expect(flash.alert).to eq "Election was not found"
      expect(page).to redirect_to :registration
    end

    it 'should redirect to reg detail if error' do
      LookupService.should_receive(:voter_elections).and_raise(LookupApi::RecordNotFound)
      get :show, uid: ''
      expect(page).to redirect_to :registration
    end
  end

end
