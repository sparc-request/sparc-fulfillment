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

module ParticipantHelper
  def us_states
    ['Alabama', 'Alaska', 'Arizona', 'Arkansas', 'California', 'Colorado', 'Connecticut', 'Delaware', 'District of Columbia', 'Florida', 'Georgia', 'Hawaii', 'Idaho', 'Illinois', 'Indiana', 'Iowa', 'Kansas', 'Kentucky', 'Louisiana', 'Maine', 'Maryland', 'Massachusetts', 'Michigan', 'Minnesota', 'Mississippi', 'Missouri', 'Montana', 'Nebraska', 'Nevada', 'New Hampshire', 'New Jersey', 'New Mexico', 'New York', 'North Carolina', 'North Dakota', 'Ohio', 'Oklahoma', 'Oregon', 'Pennsylvania', 'Puerto Rico', 'Rhode Island', 'South Carolina', 'South Dakota', 'Tennessee', 'Texas', 'Utah', 'Vermont', 'Virginia', 'Washington', 'West Virginia', 'Wisconsin', 'Wyoming', 'N/A']
  end

  def registry_details_formatter(participant)
    [
      "<a class='details participant-details ml10' href='javascript:void(0)' title='Details' participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-sunglasses'></i>",
      "</a>"
    ].join ""
  end

  def registry_actions_formatter(participant)
    destroy_array = choose_destroy_action(participant)

    return_array = [
      "<a class='edit edit-participant ml10' href='javascript:void(0)' title='Edit' participant_id='#{participant.id}'>",
      "<i class='fas fa-edit'></i>",
      "</a>",
      "&nbsp&nbsp"] + destroy_array  
    
    return_array.join ""
  end

  def editFormatter(participant, protocols_participant)
    protocol_id = protocols_participant.nil? ? nil : protocols_participant.protocol_id
    protocol_id_attr = protocol_id.nil? ? "" : "protocol_id='#{protocol_id}'"
    [
      "<a class='edit edit-participant ml10' href='javascript:void(0)' title='Edit' #{protocol_id_attr} participant_id='#{participant.id}'>",
      "<i class='glyphicon glyphicon-edit'></i>",
      "</a>"
    ].join ""
  end

  def phoneNumberFormatter(participant)
    if participant.phone.length == 10
      "#{participant.phone[0..2]}-#{participant.phone[3..5]}-#{participant.phone[6..10]}"
    else
      participant.phone
    end
  end

  def deidentified_patient(participant)
    participant.deidentified == false ? "No" : participant.deidentified == true ? "Yes" : "N/A"
  end

  def associate_formatter(participant, proto)
    associate = participant.protocol_ids.include?(protocol.id)
    protocols_participant = ProtocolsParticipant.where(protocol_id: protocol.id, participant_id: participant.id)
    protocols_participant_cannot_be_destroyed = protocols_participant.empty? ? false : !protocols_participant.first.can_be_destroyed?
    "<input class='associate' type='checkbox' " + (protocols_participant_cannot_be_destroyed && associate ? "checked='checked' disabled" : associate ? "checked='checked'" : "") + " protocol_id='#{protocol.id}' participant_id='#{participant.id}'>"
  end

  def choose_destroy_action(participant)
    if participant.can_be_destroyed?
      return ["<a class='remove destroy-participant' href='javascript:void(0)' title='Remove' participant_id='#{participant.id}' participant_name='#{participant.full_name}'>", "<i class='far fa-trash-alt'></i>", "</a>"]
    else
      return ["<a data-toggle='tooltip' data-placement='left' data-animation='false' title='Participants with procedure data cannot be deleted.'>", "<i class='far fa-trash-alt' style='cursor:default'></i>"]
    end
  end
end
