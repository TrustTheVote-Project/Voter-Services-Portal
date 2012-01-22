class FormsController < ApplicationController

  before_filter :requires_registration

  def request_absentee_status
    @req = AbsenteeStatusRequest.new

    # Set defaults
    @req.full_name  = current_registration.full_name
    @req.ssn        = current_registration.ssn
  end

end
