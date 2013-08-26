class LookupController < ApplicationController

  def registration
    render json: LookupService.registration(params[:record].symbolize_keys)
  end

  def absentee_status_history
    reg = current_registration
    render json: { success: true, items: LookupService.absentee_status_history(reg.voter_id, reg.dob, reg.vvr_county_or_city) }
  rescue LookupApi::RecordNotFound
    render json: { success: false, message: "Records not found." }
  rescue LookupApi::LookupTimeout
    render json: { success: false, message: "Servers are busy. Please retry later." }
  end

end
