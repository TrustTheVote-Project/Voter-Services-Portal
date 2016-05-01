# Registration search
class SearchController < ApplicationController

  before_filter :check_lookup_service_availability, except: :unavailable
  
  def check_lookup_service_availability
    if !lookup_service_config['enabled']
      redirect_to action: 'unavailable'
    end
  end
  
  def unavailable
    if lookup_service_config['enabled']
      redirect_to action: 'new'
    end
  end

  def new
    options = RegistrationRepository.pop_search_query(session)
    @search_query ||= SearchQuery.new(options)
    render :new
  end

  def create
    @search_query = SearchQuery.new(params[:search_query])
    return new unless @search_query.valid?

    reg = RegistrationSearch.perform(@search_query)

    if @search_query.respond_to?(:locality)
      LogRecord.identify(reg, @search_query.locality)
      RegistrationRepository.store_registration(session, reg)
      RegistrationRepository.store_lookup_data(session, @search_query)
    else
      LogRecord.identify(reg, nil)
      RegistrationRepository.store_registration(session, reg)
      #RegistrationRepository.store_lookup_data(session, @search_query)
    end
    
    redirect_to :registration
  rescue RegistrationSearch::SearchError => @error
    #if @error.kind_of? RegistrationSearch::RecordNotFound
    #  LogRecord.log("", "identify", nil, "No match for #{@search_query.to_log_details}")
    #end

    RegistrationRepository.store_search_query(session, @search_query)
    
    if !params[:continue_with_registration].blank?
      redirect_to new_registration_url(lookup_performed: true)
    else
      render :error
    end
  end

end
