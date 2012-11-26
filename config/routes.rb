VaVote::Application.routes.draw do

  get   '/not_found' => 'pages#not_found', as: 'not_found'
  get   '/p/:id'     => 'external_pages#show'

  get   '/search' => 'search#new', as: :search_form
  post  '/search' => 'search#create', as: :search

  resource :page, only: [], path: '' do
    member do
      get :front, path: ''
      get :help
      get :about
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
    get '/edit/:kind' => 'registrations#edit'
  end
  get '/voter_card.pdf' => 'voter_cards#show', format: 'pdf', as: 'voter_card'

  get '/register/residential' => 'registrations#new', defaults: { residence: 'in' }, as: 'register_residential'
  get '/register/overseas'    => 'registrations#new', defaults: { residence: 'outside' }, as: 'register_overseas'

  resource :form, only: [] do
    member do
      get :request_absentee_status
    end
  end

  namespace :admin do
    root to: 'log_records#index'
    resources :log_records, only: [ :index, :show ]
  end

  namespace :api do
    get '/search' => 'registrations#show', format: 'json'
  end

  root to: "pages#front"

end
