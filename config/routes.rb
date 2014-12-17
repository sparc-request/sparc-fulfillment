Rails.application.routes.draw do
  devise_for :users
  mount API::Base => '/'
  root 'protocols#index'

  resources :protocols do
    resources :arms do
      member do
        get 'change'
      end
      resources :visit_groups
    end

    # member do
    #   get 'change_arm'
    # end
    resources :participants
  end
end



