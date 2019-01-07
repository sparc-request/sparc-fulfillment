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

FactoryBot.define do

  factory :visit do
    line_item nil
    visit_group nil
    sparc_id
    research_billing_qty 0
    insurance_billing_qty 0
    effort_billing_qty 0

    trait :with_complete_procedures do
      association :line_item, :with_service
      after(:create) do |visit, evaluator|
        create_list(:procedure_complete, 3, visit: visit)
      end
    end

    trait :with_incomplete_procedures do
      after(:create) do |visit, evaluator|
        create_list(:procedure_incomplete, 3, visit: visit)
      end
    end

    trait :with_billing do
      research_billing_qty 1
      insurance_billing_qty 1
      effort_billing_qty 1
    end

    trait :without_billing do
      research_billing_qty 0
      insurance_billing_qty 0
      effort_billing_qty 0
    end

    factory :visit_with_complete_and_incomplete_procedures, traits: [:with_complete_procedures, :with_incomplete_procedures]
    factory :visit_with_billing, traits: [:with_billing]
    factory :visit_without_billing, traits: [:without_billing]
  end
end
