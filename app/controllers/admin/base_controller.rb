class Admin::BaseController < ApplicationController

  layout 'admin'

  before_filter :authenticate, :if => lambda { Rails.env.production? }

  private

  def authenticate
    authenticate_or_request_with_http_basic("VA Voter Portal Admin") do |user, password|
      a = AppConfig['admin']
      p = a['pass']
      p.present? && p == password && a['user'] == user
    end
  end

end
