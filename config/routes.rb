# Copyright © 2011-2016 MUSC Foundation for Research Development~
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
    devise_for :identities, :controllers => { :omniauth_callbacks => "identities/omniauth_callbacks" }, :path_names => {:sign_in => 'auth/shibboleth' }
  else # add Shibboleth as an option and allow users to view 'sign in' page
    devise_for :identities, :controllers => { :omniauth_callbacks => "identities/omniauth_callbacks" }
  end

  resources :protocols
  resources :visit_groups, only: [:new, :create, :edit, :update, :destroy]
  resources :components, only: [:update]
  resources :fulfillments
  resources :procedures, only: [:create, :edit, :update, :destroy]
  resources :notes, only: [:index, :new, :create]
  resources :documents
  resources :line_items
  resources :visits, only: [:update]
  resources :custom_appointments, controller: :appointments

  resources :reports, only: [:new, :create] do
    collection do
      resource :update_dropdown, only: [:create]
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

  resources :participants do
    get 'change_arm(/:id)', to: 'participants#edit_arm'
    post 'change_arm(/:id)', to: 'participants#update_arm'
    get 'details', to: 'participants#details'
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
    put 'update_statuses'
  end


  resources :multiple_line_items, only: [] do
    collection do
      get 'new_line_items'
      put 'create_line_items'
      get 'edit_line_items'
      put 'destroy_line_items'
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
