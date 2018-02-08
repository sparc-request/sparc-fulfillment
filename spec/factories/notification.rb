# Copyright © 2011-2018 MUSC Foundation for Research Development~
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

FactoryGirl.define do

  factory :notification, aliases: [:notification_protocol_create] do
    sparc_id 1
    kind 'Protocol'
    action 'create'
    callback_url 'http://localhost:5000/v1/protocols/1.json'

    trait :protocol do
      kind 'Protocol'
      callback_url 'http://localhost:5000/v1/protocols/1.json'
    end

    trait :study do
      kind 'Study'
      callback_url 'http://localhost:5000/v1/study/1.json'
    end

    trait :service do
      kind 'Service'
      callback_url 'http://localhost:5000/v1/services/1.json'
    end

    trait :sub_service_request do
      kind 'SubServiceRequest'
      callback_url 'http://localhost:5000/v1/sub_service_requests/1.json'
    end

    trait :create do
      action 'create'
    end

    trait :update do
      action 'update'
    end

    factory :notification_service_create,             traits: [:service, :create]
    factory :notification_service_update,             traits: [:service, :update]
    factory :notification_protocol_update,            traits: [:protocol, :update]
    factory :notification_study_update,               traits: [:study, :update]
    factory :notification_sub_service_request_create, traits: [:sub_service_request, :create]
    factory :notification_sub_service_request_update, traits: [:sub_service_request, :update]
  end
end
