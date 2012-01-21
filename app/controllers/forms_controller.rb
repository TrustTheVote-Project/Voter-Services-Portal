class FormsController < ApplicationController

  #before_filter :requires_registration

  def request_absentee_status
    @req = AbsenteeStatusRequest.new
  end

end
