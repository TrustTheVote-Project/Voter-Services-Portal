class LookupController < ApplicationController

  rescue_from LookupApi::RecordNotFound do |ex|
    render json: { success: true, items: [] }
  end

  rescue_from LookupApi::LookupTimeout do |ex|
    render json: { success: false, message: "Servers are busy. Please retry later." }
  end

  def registration
    render json: LookupService.registration(params[:record].symbolize_keys)
  end

  def absentee_status_history
    reg = current_registration
    items = LookupService.absentee_status_history(reg.voter_id, reg.dob, reg.vvr_county_or_city)
    items = items.each do |i|
      i[:request] = I18n.t("view.absentee_status.request.#{i[:request]}") || i[:request] unless i[:request].blank?
      i[:action]  = I18n.t("view.absentee_status.action.#{i[:action]}") || i[:action] unless i[:action].blank?
      i[:notes]   = I18n.t("view.absentee_status.notes.#{i[:notes]}") || i[:notes] unless i[:notes].blank?
    end
    render json: { success: true, items: items }
  end

  def my_ballot
    reg = current_registration

    elections = LookupService.voter_elections(reg.voter_id).map do |e|
      { url:  my_ballot_election_path(e[:id]),
        name: e[:name] }
    end

    render json: { success: true, items: elections }
  end

end
