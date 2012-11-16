class Admin::LogRecordsController < Admin::BaseController

  inherit_resources
  respond_to :xml, :html

  protected

  def collection
    @log_records ||= end_of_association_chain.order('created_at desc').page(params[:page])
  end

end
