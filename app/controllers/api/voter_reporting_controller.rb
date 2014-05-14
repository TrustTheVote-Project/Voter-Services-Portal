class Api::VoterReportingController < ActionController::Base

  # looks up the voter record and lists the polling location
  def lookup
    sq  = SearchQuery.new(params)
    res = PollingLocationsSearch.perform(sq)

    queued_voter = QueuedVoter.find_or_create_by_voter_id(res[:voter_id])

    render json: { token: queued_voter.token, polling_locations: res[:polling_locations] }
  rescue LookupApi::SearchError => e
    render json: { error: e.message }, status: :not_found
  end

  # report the arrival to a polling location
  def report_arrive
    report.arrived_at = Time.now.utc
    report.save

    render json: {}
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Voter not found' }, status: :not_found
  end

  # report the completion of voting at a polling location
  def report_complete
    report.completed_at = Time.now.utc
    report.save

    render json: {}
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Voter not found' }, status: :not_found
  end

  private

  def qv
    @qv ||= QueuedVoter.find_by_token(params[:token])
  end

  def report
    @report ||= qv.reports.find_or_initialize_by_polling_location_id(params[:polling_location_id])
  end

end
