class Api::VoterReportingController < ActionController::Base

  class ReportingError < StandardError; end
  class NotFound < StandardError; end

  rescue_from ReportingError do |e|
    render json: { error: e.message }, status: 401
  end

  rescue_from NotFound do |e|
    render json: { error: e.message }, status: :not_found
  end

  # looks up the voter record and lists the polling location
  def polling_location
    render json: { polling_locations: queued_voter.polling_locations }
  rescue LookupApi::SearchError => e
    raise NotFound, e.message
  end

  # report the arrival to a polling location
  def report_arrive
    unless report.completed_at.blank?
      raise ReportingError, "Can't report arrival after completion"
    end

    report.arrived_at = Time.now.utc
    report.save

    render json: {}
  end

  # report the completion of voting at a polling location
  def report_complete
    if report.arrived_at.blank?
      raise ReportingError, "Can't record completion before the arrival"
    end

    unless report.completed_at.blank?
      raise ReportingError, "Can't record completion more than once"
    end

    report.completed_at = Time.now.utc
    report.save

    render json: {}
  end

  def wait_time_info
    reports = queued_voter.reports.where(polling_location_id: params[:polling_location_id])
    lc = reports.completed.order('completed_at DESC').first

    render json: {
      last_completion: lc ? { waited: lc.waited, completed_at: lc.completed_at.strftime('%Y-%m-%d %H:%M:%S') } : nil,
      waiting_count:   reports.waiting.count,
      completed_count: reports.completed.count
    }
  end

  private

  def queued_voter
    @queued_voter ||= begin
      sq = SearchQuery.from_eml310_json(params[:q])
      if !sq.valid?
        raise ReportingError, "Invalid lookup parameters: #{sq.errors.full_messages.join(', ')}"
      end

      res = PollingLocationsSearch.perform(sq)
      QueuedVoter.find_or_create_by_voter_id(res[:voter_id], polling_locations: res[:polling_locations])
    end
  end

  def report
    @report ||= queued_voter.reports.find_or_initialize_by_polling_location_id(params[:polling_location_id])
  end

end
