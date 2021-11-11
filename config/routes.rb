VaVote::Application.routes.draw do

  # Add localized scope if alternate localizations are present,
  # otherwise directly add unprefixed routes.
  def conditional_scope(localized_route, root_url, &block)
    unless AppConfig['SupportedLocalizations'].blank?
      scope(localized_route, &block)
      get '/' => root_url # Add root_url outside of localized route.
    else
      block.call
    end
  end

  get '/lookup/registration'            => 'lookup#registration'
    
  namespace :api do
    get '/search(.json)' => 'registrations#show', format: 'json'

    namespace :v1, module: nil do
      get '/demo'            => 'voter_reporting#demo', as: 'demo'
      get '/PollingLocation' => 'voter_reporting#polling_location'
      get '/ReportArrive'    => 'voter_reporting#report_arrive'
      get '/ReportComplete'  => 'voter_reporting#report_complete'
      get '/WaitTimeInfo'    => 'voter_reporting#wait_time_info'
    end
  end



  root_url = AppConfig['demo'] ? 'pages#demo_splash' : "pages#front"
  conditional_scope "/:locale", root_url do

    get   '/not_found'                    => 'pages#not_found', as: 'not_found'

    get   '/registration/new/privacy'     => 'pages#privacy', defaults: { path: 'new_registration' }, as: 'new_registration_privacy'
    get   '/registration/edit/privacy'    => 'pages#privacy', defaults: { path: 'edit_registration' }, as: 'edit_registration_privacy'
    get   '/registration/request_absentee/privacy' => 'pages#privacy', defaults: { path: 'request_absentee_registration' }, as: 'request_absentee_registration_privacy'
    get   '/register/residential/privacy' => 'pages#privacy', defaults: { path: 'register_residential' }, as: 'register_residential_privacy'
    get   '/register/overseas/privacy'    => 'pages#privacy', defaults: { path: 'register_overseas' }, as: 'register_overseas_privacy'

    get   '/search'                       => 'search#new', as: 'search_form'
    get   '/search/unavailable'           => 'search#unavailable'
    post  '/search'                       => 'search#create', as: 'search'

    get   '/register/residential'         => 'registrations#new', defaults: { residence: 'in' }, as: 'register_residential'
    get   '/register/overseas'            => 'registrations#new', defaults: { residence: 'outside' }, as: 'register_overseas'

    get   '/status'                       => 'status#show', as: 'status'
    post  '/status'                       => 'status#search'

    resource :page, only: [], path: '' do
      member do
        get :front, path: AppConfig['demo'] ? '/front' : ''
        get :help
        get :about
        get :about_update_absentee
        get :contact
        get :faq
        get :elections
        get :security
        get :feedback
        get :about_registration
        get :about_update_absentee
        get :online_ballot_marking
        AppConfig.fetch('HeaderLinks', []).each do |settings|
          get settings["url"]
        end
      end
    end

    resource :registration, except: :destroy do
      get '/edit' => 'registrations#edit'
      get '/request_absentee' => 'registrations#edit', defaults: { request_absentee: true }, as: 'request_absentee'
    end
    resource :absentee_request, only: [:new, :create, :edit, :update] do
      get '/not_available' => 'absentee_requests#not_available'
    end
    get '/voter_card.pdf' => 'voter_cards#show', format: 'pdf', as: 'voter_card'


    get '/lookup/absentee_status_history' => 'lookup#absentee_status_history'
    get '/lookup/my_ballot'               => 'lookup#my_ballot'

    get '/ballot_info/:election_uid'      => 'ballot_info#show', as: 'ballot_info'

    resource :form, only: [] do
      member do
        get :request_absentee_status
      end
    end


    root to: root_url
  end
    
  
  match '*unmatched_route', :to => 'application#raise_not_found!'
  
end
