Rails.application.routes.draw do

  devise_for :identities

  resources :protocols
  resources :visit_groups
  resources :components, only: [:update]
  resources :fulfillments, only: [:new, :create, :edit, :update]
  resources :procedures, only: [:create, :edit, :update, :destroy]
  resources :notes, only: [:index, :new, :create]
  resources :documents, only: [:index, :new, :create]
  resources :line_items, only: [:new, :create, :edit, :update]
  resources :visits, only: [:update]

  resources :visit_groups do
    collection do
      get 'update_positions_on_arm_change', to: 'visit_groups#update_positions_on_arm_change'
    end
  end

  resources :reports do
    collection do
      get 'new_billing_report'
      post 'create_billing_report'

      get 'new_auditing_report'
      post 'create_auditing_report'

      get 'new_participant_report'
      post 'create_participant_report'

      get 'new_project_summary_report'
      post 'create_project_summary_report'
    end
  end

  resources :arms do
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

  resources :custom_appointments, :controller => :appointments

  resources :multiple_line_items, only: [] do
    collection do
      get 'new_line_items'
      get 'edit_line_items'
      get 'necessary_arms'
      put 'update_line_items'
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
