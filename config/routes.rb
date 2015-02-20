Rails.application.routes.draw do

  devise_for :users

  resources :appointments, only: [:show]
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
      get 'change_arm(/:id)', to: 'participants#edit_arm'
      post 'change_arm(/:id)', to: 'participants#update_arm'
      get 'completed_appointments', to: 'participants#completed_appointments'
      get 'select_appointment/(:id)', to: 'participants#select_appointment'
    end
  end

  resources :procedures, only: [:create, :destroy] do
    resources :notes do
    end
  end

  resources :service_calendar, only: [] do
    collection do
      get 'change_page'
      get 'change_tab'
      put 'check_visit'
      put 'change_quantity'
      put 'change_visit_name'
      get 'edit_service'
      patch 'update_service'
      put 'check_row'
      put 'check_column'
      put 'remove_line_item'
    end
  end

  get 'multiple_line_items/(:protocol_id)/(:service_id)/necessary_arms', to: 'multiple_line_items#necessary_arms'
  get 'multiple_line_items/(:protocol_id)/(:service_id)/new', to: 'multiple_line_items#new'
  get 'multiple_line_items/(:protocol_id)/(:service_id)/edit', to: 'multiple_line_items#edit'
  put 'multiple_line_items/update', to: 'multiple_line_items#update'

  mount API::Base => '/'

  root 'protocols#index'
end



