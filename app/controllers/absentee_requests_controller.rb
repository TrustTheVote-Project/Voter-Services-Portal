class AbsenteeRequestsController < ApplicationController

  def new
    @abr = AbsenteeRequest.new
  end
  
  
  
end