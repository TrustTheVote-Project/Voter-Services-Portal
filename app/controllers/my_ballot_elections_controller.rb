class MyBallotElectionsController < ApplicationController

  before_filter :requires_registration

  def show
    election_uid = params[:uid]
    voter_id     = current_registration.voter_id

    elections = LookupService.voter_elections(voter_id)
    @election = elections.find { |e| e[:id] == election_uid }

    raise LookupApi::RecordNotFound if @election.nil?

  rescue LookupApi::RecordNotFound
    redirect_to :registration, alert: 'Election was not found'
  end

end
