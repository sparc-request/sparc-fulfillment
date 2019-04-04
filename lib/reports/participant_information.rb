# Copyright © 2011-2019 MUSC Foundation for Research Development~
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

class ParticipantInformation

  require 'csv'

  def generate

    participants = Participant.all

    CSV.open("participant_info.csv", "wb") do |csv|
      csv << ["Protocol ID", "Request ID", "(Service Provider) Organization", "Short Title", "Long Title", "PI Name", "Funding Source", "Arm Name", "Patient ID", "Patient MRN", "Patient Name", "Patient Middle Initial", "Patient Status", "Patient Date of Birth", "Patient Gender", "Patient Ethnicity", "Patient Race", "Patient Address", "Patient Phone #", "City", "State", "Zip Code", "External ID"]
      participants.each do |participant|
        csv << [
           participant.protocol_id,
           participant.protocol.sub_service_request_id,
           participant.protocol.try(:organization).try(:name),
           participant.protocol.short_title,
           participant.protocol.title,
           participant.protocol.pi.full_name,
           participant.protocol.funding_source,
           participant.try(:arm).try(:name),
           participant.id,
           participant.mrn,
           "#{participant.first_name} #{participant.last_name}",
           participant.middle_initial,
           participant.status,
           participant.date_of_birth,
           participant.gender,
           participant.ethnicity,
           participant.race,
           participant.address,
           participant.phone,
           participant.city,
           participant.state,
           participant.zipcode,
           participant.sparc_id
        ]
      end
    end
  end
end
