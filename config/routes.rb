# Copyright © 2011-2023 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

Rails.application.routes.draw do

  if ENV.fetch('USE_SHIBBOLETH_ONLY') == 'true' # Shibboleth is the only authentication option and all URLs are protected by it
    devise_for :identities,
               controllers: {
                 omniauth_callbacks: 'identities/omniauth_callbacks'
               }, path_names: { sign_in: 'auth/shibboleth' }
  else # add Shibboleth as an option and allow users to view 'sign in' page
    devise_for :identities,
               controllers: {
                  omniauth_callbacks: 'identities/omniauth_callbacks' }
  end

  resources :protocols, only: [:index, :show] do
    member do
      get :refresh_tab
    end

    resources :participants, controller: :protocols_participants do
      collection do
        get 'protocols_participants_in_protocol'
        get 'associate_participants_to_protocol'
        post 'update_protocol_association', to: 'participants#update_protocol_association'
        get 'search', to: 'participants#search'
      end

      member do
        get 'calendar', to: 'protocols_participants#show', as: 'calendar'
        put 'update', to: 'protocols_participants#update'
        delete :destroy, as: 'destroy'
      end

      put 'change_recruitment_source(/:id)', to: 'participants#update_recruitment_source'
      put 'change_status(/:id)', to: 'participants#update_status'
    end
  end

  resources :participants do
    get 'details', to: 'participants#details'
  end

  resources :visit_groups, only: [:new, :create, :edit, :update, :destroy]
  resources :components, only: [:update]
  resources :notes, only: [:index, :create, :edit, :update, :destroy]
  resources :documents
  resources :line_items, only: [:index, :edit, :update]
  resources :visits, only: [:edit, :update]
  resources :custom_appointments, controller: :appointments
  resources :imports
  resources :tasks, only: [:index, :show, :new, :create, :update, :edit]

  resources :reports, only: [:new, :create] do
    collection do
      get 'update_services_protocols_dropdown'
      get 'update_protocols_dropdown'
      get 'reset_services_dropdown'
    end
  end

  resources :fulfillments do
    collection do
      put 'toggle_invoiced(/:id)', to: 'fulfillments#toggle_invoiced'
      put 'toggle_credit(/:id)', to: 'fulfillments#toggle_credit'
      get 'invoiced_date_edit/:id(.:format)', to: 'fulfillments#invoiced_date_edit'
    end
  end

  resources :arms, only: [:new, :create, :update, :destroy] do
    collection do
      get 'navigate', to: "arms#navigate_to_arm"
    end
  end

  resources :visit_groups, only: [:new, :create, :update, :destroy] do
    collection do
      get 'navigate', to: 'visit_groups#navigate_to_visit_group'
    end
  end

  resources :appointments do
    member do
      put :update_statuses
      put :change_visit_type
    end

    collection do
      get 'completed_appointments'
    end

    get 'change_appointment_style'

    resources :procedures, only: [:index, :create, :edit, :invoiced_date_edit, :update, :destroy] do
      member do
        put 'change_procedure_position(/:id)', to: 'procedures#change_procedure_position', as: 'change_position'
      end
    end

    resources :multiple_procedures, only: [] do
      collection do
        get 'incomplete_all'
        get 'complete_all'
        put 'update_procedures'
        put 'reset_procedures'
      end
    end
  end


  resources :multiple_line_items, only: [] do
    collection do
      get 'new_line_items'
      put 'create_line_items'
      get 'edit_line_items'
      put 'destroy_line_items'
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

  get 'sub_service_request/:id', to: redirect { |params, request|
    protocol_id = Protocol.where(sub_service_request_id: params[:id]).first.id
    "/protocols/#{protocol_id}"
  }

  mount API::Base => '/'

  root 'protocols#index'
end
