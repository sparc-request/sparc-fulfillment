# Copyright © 2011-2017 MUSC Foundation for Research Development~
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

  factory :procedure do
    appointment nil
    visit nil

    trait :insurance_billing_qty do
      billing_type 'insurance_billing_qty'
    end

    trait :research_billing_qty do
      billing_type 'research_billing_qty'
    end

    trait :complete do
      association :service, factory: :service
      association :appointment, :with_arm, :without_validations

      status 'complete'
      completed_date Date.today.strftime('%m/%d/%Y')
    end

    trait :incomplete do
      status 'incomplete'
      completed_date nil
      incompleted_date Date.today.strftime('%m/%d/%Y')
    end

    trait :follow_up do
      status 'follow_up'
      completed_date nil
      after(:create) do |procedure, evaluator|
        create(:task, assignable: procedure)
      end
    end

    trait :unstarted do
    end

    trait :with_notes do
      after(:create) do |procedure, evaluator|
        create_list(:note, 3, notable: procedure)
      end
    end

    trait :with_task do
      after(:create) do |procedure, evaluator|
        create(:task, assignable: procedure)
      end
    end

    factory :procedure_insurance_billing_qty_with_notes, traits: [:insurance_billing_qty, :with_notes]
    factory :procedure_research_billing_qty_with_notes, traits: [:research_billing_qty, :with_notes]
    factory :procedure_complete, traits: [:complete]
    factory :procedure_incomplete, traits: [:incomplete]
    factory :procedure_with_notes, traits: [:with_notes]
    factory :procedure_follow_up, traits: [:follow_up]
  end
end
