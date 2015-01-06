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

    resources :participants do
      get 'change_arm/(:id/edit)', to: 'participants#edit_arm', as: :edit_arm
      patch 'change_arm(/:id)', to: 'participants#update_arm'
      put 'change_arm(/:id)', to: 'participants#update_arm'
      post 'change_arm(/:id)', to: 'participants#update_arm'
    end
  end

  resources :service_calendar, only: [] do
    collection do
      get 'change_page'
      get 'change_tab'
      put 'check_visit'
      put 'change_quantity'
      put 'change_visit_name'
      put 'check_row'
      put 'check_column'
      put 'remove_line_item'
    end
  end
end



