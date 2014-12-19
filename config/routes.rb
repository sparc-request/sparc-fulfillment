Rails.application.routes.draw do
  devise_for :users
  mount API::Base => '/'
  root 'protocols#index'

  resources :protocols do
    resources :arms do
      member do
        get 'change'
      end
      resources :services do
        resources :line_items do
        end
      end
      resources :visit_groups
    end
    resources :participants do
      get 'change_arm/(:id/edit)', to: 'participants#edit_arm', as: :edit_arm
      patch 'change_arm(/:id)', to: 'participants#update_arm'
      put 'change_arm(/:id)', to: 'participants#update_arm'
      post 'change_arm(/:id)', to: 'participants#update_arm'
    end
  end

  resources :service_calendar, only: [:change_page] do
    collection do
      get 'change_page'
    end
  end
end



