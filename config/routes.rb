VaVote::Application.routes.draw do

  get   '/not_found' => 'pages#not_found', as: :not_found

  resource :registration, only: [ :show, :new ]

  get   '/search' => 'search#new', as: :search_form
  post  '/search' => 'search#create', as: :search

  resource :page, only: [], path: '' do
    member do
      get :front, path: ''
      get :help
      get :about
      get :faqs
      get :security
      get :feedback
    end
  end

  resource :registration_request, only: [ :new, :create, :show ]
  get '/register/residential' => 'registration_requests#new', defaults: { kind: 'residential' }, as: 'register_residential'
  get '/register/overseas'    => 'registration_requests#new', defaults: { kind: 'overseas' }, as: 'register_overseas'

  resource :form, only: [] do
    member do
      get :request_absentee_status
    end
  end

  namespace :admin do
    root to: 'log_records#index'
    resources :log_records, only: [ :index, :show ]
  end

  root to: "pages#front"

end
