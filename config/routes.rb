Rails.application.routes.draw do

  devise_for :identities, :controllers => { :omniauth_callbacks => "identities/omniauth_callbacks" }, :path_names => {:sign_in => 'auth/shibboleth' }
    
  resources :protocols
  resources :visit_groups, only: [:new, :create, :edit, :update, :destroy]
  resources :components, only: [:update]
  resources :fulfillments, only: [:new, :create, :edit, :update]
  resources :procedures, only: [:create, :edit, :update, :destroy]
  resources :notes, only: [:index, :new, :create]
  resources :documents
  resources :line_items
  resources :visits, only: [:update]
  resources :reports, only: [:new, :create]
  resources :arms
  resources :custom_appointments, controller: :appointments

  resources :visit_groups do
    collection do
      get 'update_positions_on_arm_change', to: 'visit_groups#update_positions_on_arm_change'
    end
  end

  resources :participants do
    get 'change_arm(/:id)', to: 'participants#edit_arm'
    post 'change_arm(/:id)', to: 'participants#update_arm'
    get 'details', to: 'participants#details'
    put 'set_recruitment_source', to: 'participants#set_recruitment_source'
  end

  resources :tasks do
    member do
      get 'task_reschedule'
    end
  end

  resources :appointments do
    collection do
      get 'completed_appointments'
    end
  end


  resources :multiple_line_items, only: [] do
    collection do
      get 'new_line_items'
      get 'edit_line_items'
      get 'necessary_arms'
      put 'update_line_items'
    end
  end

  resources :multiple_procedures, only: [] do
    collection do
      get 'incomplete_all'
      put 'update_procedures'
    end
  end

  resources :study_schedule, only: [] do
    collection do
      get 'change_page'
      get 'change_tab'
      put 'check_row'
      put 'check_column'
    end
  end

  mount API::Base => '/'

  root 'protocols#index'
end
