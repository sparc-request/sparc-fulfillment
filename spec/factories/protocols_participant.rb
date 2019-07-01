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

  factory :protocols_participant do
    arm nil
    protocol nil
    participant nil
    status { Participant::STATUS_OPTIONS.select{|stat| stat != 'Screening'}.sample }

    trait :with_protocol do 
      protocol  
    end

    trait :with_appointments do
      after(:create) do | protocols_participant, evaluator|
        protocols_participant.arm.visit_groups.each do |vg|
          create(:appointment,
                  protocols_participant_id: protocols_participant.id,
                  visit_group: vg,
                  name: vg.name,
                  visit_group_position: vg.position,
                  arm_id: vg.arm_id,
                  position: protocols_participant.appointments.count + 1)
        end
      end
    end

    trait :with_completed_appointments do
      after(:create) do | protocols_participant, evaluator|
        protocols_participant.arm.visit_groups.each do |visit_group|
          create(:appointment,
                  protocols_participant: protocols_participant,
                  visit_group: visit_group,
                  name: visit_group.name,
                  visit_group_position: visit_group.position,
                  arm_id: visit_group.arm_id,
                  position: protocols_participant.appointments.count + 1,
                  completed_date: Time.current + visit_group.id.days)
        end
      end
    end

    factory :protocols_participant_with_protocol, traits: [:with_protocol]
    factory :protocols_participant_with_appointments, traits: [:with_appointments]
    factory :protocols_participant_with_completed_appointments, traits: [:with_completed_appointments]
  end
end
