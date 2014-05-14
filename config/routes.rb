VaVote::Application.routes.draw do

  get   '/not_found'                    => 'pages#not_found', as: 'not_found'

  get   '/registration/new/privacy'     => 'pages#privacy', defaults: { path: 'new_registration' }, as: 'new_registration_privacy'
  get   '/registration/edit/privacy'    => 'pages#privacy', defaults: { path: 'edit_registration' }, as: 'edit_registration_privacy'
  get   '/registration/request_absentee/privacy' => 'pages#privacy', defaults: { path: 'request_absentee_registration' }, as: 'request_absentee_registration_privacy'
  get   '/register/residential/privacy' => 'pages#privacy', defaults: { path: 'register_residential' }, as: 'register_residential_privacy'
  get   '/register/overseas/privacy'    => 'pages#privacy', defaults: { path: 'register_overseas' }, as: 'register_overseas_privacy'

  get   '/search'                       => 'search#new', as: 'search_form'
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
      get :faq
      get :elections
      get :security
      get :feedback
      get :about_registration
      get :about_update_absentee
      get :online_ballot_marking
    end
  end

  resource :registration, except: :destroy do
    get '/edit' => 'registrations#edit'
    get '/request_absentee' => 'registrations#edit', defaults: { request_absentee: true }, as: 'request_absentee'
  end
  get '/voter_card.pdf' => 'voter_cards#show', format: 'pdf', as: 'voter_card'

  get '/lookup/registration'            => 'lookup#registration'
  get '/lookup/absentee_status_history' => 'lookup#absentee_status_history'
  get '/lookup/my_ballot'               => 'lookup#my_ballot'

  get '/ballot_info/:election_uid'      => 'ballot_info#show', as: 'ballot_info'

  resource :form, only: [] do
    member do
      get :request_absentee_status
    end
  end

  namespace :api do
    get '/search(.json)' => 'registrations#show', format: 'json'

    namespace :voter_reporting, module: nil do
      get '/lookup'          => 'voter_reporting#lookup'
      get '/report_arrive'   => 'voter_reporting#report_arrive'
      get '/report_complete' => 'voter_reporting#report_complete'
    end
  end

  if AppConfig['demo']
    root to: 'pages#demo_splash'
  else
    root to: "pages#front"
  end

end
