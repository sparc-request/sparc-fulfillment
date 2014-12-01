Rails.application.routes.draw do
  devise_for :users
  mount API::Base => '/'
  root 'protocols#index'

  resources :protocols do
    member do
      get 'change_arm'
    end
    resources :participants
  end
end



