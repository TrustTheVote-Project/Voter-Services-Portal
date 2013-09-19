class BallotInfoController < ApplicationController

  before_filter :requires_registration

  def show
    election_uid = params[:election_uid]
    voter_id     = current_registration.voter_id

    info = LookupService.ballot_info(voter_id, election_uid)

    raise LookupApi::RecordNotFound if info.nil?

    @info = BallotInfoPresenter.new(info)
  rescue LookupApi::RecordNotFound
    redirect_to :registration, alert: 'Election was not found'
  rescue LookupApi::LookupTimeout
    render :servers_busy
  end

end
