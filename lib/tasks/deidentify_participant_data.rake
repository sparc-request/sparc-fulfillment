# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

require 'faker'

namespace :data do

  desc 'DeIdentify Participant Data'
  task deidentify_participant_data: :environment do

    Participant.with_deleted.update_all(mrn: nil)

    bar = ProgressBar.new(Participant.with_deleted.count)

    Participant.with_deleted.find_each do |participant|
      participant.update_attributes(
        first_name: Faker::Name.first_name,
        last_name: Faker::Name.last_name,
        mrn: participant.id,
        date_of_birth: Faker::Date.birthday(min_age: 18, max_age: 85).strftime("%m/%d/%Y"),
        gender: "Unknown",
        ethnicity: "Unknown/Other/Unreported",
        race: "Unknown/Other/Unreported",
        address: Faker::Address.street_address,
        phone: Faker::Number.number(digits: 10),
        city: Faker::Address.city,
        state: Faker::Address.state_abbr,
        zipcode: "12345",
        middle_initial: "D"
        )

      bar.increment!
    end
  end
end
