require 'spec_helper'

describe BallotInfoController do

  describe 'show' do
    let(:reg) { double(voter_id: "600000000") }

    before do
      controller.stub(current_registration: reg)
    end

    it 'should render election page', :vcr do
      get :show, election_uid: '6002FDB4-FC9C-4F36-A418-C0BDFFF2E579'
      expect(assigns(:info).election_name).to eq "2012 November General Election"
      expect(page).to render_template :show
    end

    it 'should redirect to registration details if election was not found', :vcr do
      get :show, election_uid: 'missing'
      expect(flash.alert).to eq "Election was not found"
      expect(page).to redirect_to :registration
    end

    it 'should redirect to reg detail if error', :vcr do
      expect(LookupService).to receive(:ballot_info).and_raise(LookupApi::RecordNotFound)
      get :show, election_uid: ''
      expect(page).to redirect_to :registration
    end

    it 'should render server_busy template' do
      expect(LookupService).to receive(:ballot_info).and_raise(LookupApi::LookupTimeout)
      get :show, election_uid: ''
      expect(page).to render_template :servers_busy
    end
  end

end
