class AbsenteeRequestsController < ApplicationController

  def new
    if AppConfig['OVR']['options']['enable_absentee_domestic_new'] == false
      redirect_to not_available_absentee_request_path and return
    end
      
    @abr = AbsenteeRequest.new
  end
  
  def not_available
  end
  
  
  
end