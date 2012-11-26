class Api::RegistrationsController < ActionController::Base

  class InvalidSearchQuery < StandardError; end

  # searches for registrations
  def show
    cb = params.delete(:cb)
    params[:lookup_type] = params[:voter_id].present? ? 'voter_id' : 'ssn4'

    @query = build_search_query
    @reg   = RegistrationSearch.perform(@query)

    render_response cb, render_to_string(:show)
  rescue InvalidSearchQuery
    render_error cb, 'Invalid search parameters'
  rescue RegistrationSearch::RecordNotFound
    render_error cb, 'Record not found'
  end

  private

  # builds search query from request parameters or
  # raises the #InvalidSearchQuery# if parameters are incomplete.
  def build_search_query
    p     = params.except('action', 'controller')
    dob   = (d = params.delete(:dob)).present? ? Date.parse(d) : nil
    query = SearchQuery.new(p.merge(dob: dob))

    raise InvalidSearchQuery unless query.valid?

    query
  end

  # renders the error
  def render_error(cb, msg)
    @json_response = { success: false, error: msg }
    json = @json_response.to_json
    render text: (cb ? "#{cb}(#{json})" : json), status: (cb ? 200 : 500)
  end

  # renders json
  def render_response(cb, json)
    render text: (cb ? "#{cb}(#{json})" : json)
  end

end
