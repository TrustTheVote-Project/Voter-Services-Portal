VaVote::Application.routes.draw do

  get   '/not_found' => 'pages#not_found', as: :not_found

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
      get :about_registration
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

  root to: "pages#front"

end
