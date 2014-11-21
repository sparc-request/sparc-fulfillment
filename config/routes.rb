Rails.application.routes.draw do
  mount API::Base => '/'
  root 'protocols#index'

  resources :protocols do
    member do
      get 'show'
      post 'create_participant'
    end
  end

end
