class Api::RegistrationsController < ActionController::Metal

  class InvalidSearchQuery < StandardError; end

  include ActionController::Rendering

  # searches for registrations
  def show
    @query = build_search_query
    render_json success: true, record: ''
  rescue InvalidSearchQuery
    render_error 'Invalid search parameters'
  end

  private

  # builds search query from request parameters or
  # raises the #InvalidSearchQuery# if parameters are incomplete.
  def build_search_query
    p     = params.except('action', 'controller')
    query = SearchQuery.new(p)

    raise InvalidSearchQuery unless query.valid?

    query
  end

  # renders the error
  def render_error(msg)
    @json_response = { success: false, error: msg }
    render text: @json_response.to_json, status: 500
  end

  # renders json
  def render_json(hash)
    @json_response = hash
    render text: @json_response.to_json
  end

end
