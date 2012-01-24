class Admin::LogRecordsController < Admin::BaseController

  inherit_resources

  protected

  def collection
    @log_records ||= end_of_association_chain.order('created_at desc').page(params[:page])
  end

end
