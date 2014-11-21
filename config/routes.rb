Rails.application.routes.draw do
  mount API::Base => '/'
  root 'protocols#index'

  resources :protocols do
    member do
      get 'show'
    end

    collection do
      get :protocols_by_status
    end
  end

end
