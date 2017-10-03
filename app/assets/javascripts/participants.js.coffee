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

$ ->

  $('#completed-appointments-table').on 'click-row.bs.table', (row, $element) ->
    $.ajax
      type: 'GET'
      url: "/appointments/#{$element.id}.js"

  $(document).on 'click', '.new-participant', ->
    data =
      'protocol_id' : $(this).data('protocol-id')

    $.ajax
      type: 'GET'
      url: "/participants/new.js"
      data: data

  $(document).on 'click', '.remove-participant', ->
    participant_id = $(this).attr('participant_id')
    name = $(this).attr('participant_name')
    del = confirm "Are you sure you want to delete #{name} from the Participant List?"
    if del
      $.ajax
        type: 'DELETE'
        url: "/participants/#{participant_id}"

  $(document).on 'click', '.edit-participant', ->
    participant_id = $(this).attr('participant_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/edit"

  $(document).on 'click', '.participant-details', ->
    participant_id = $(this).attr('participant_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/details"

(exports ? this).refreshParticipantTables = ->
  $("#participants-list-table").bootstrapTable 'refresh', {silent: true}
  $("#participants-tracker-table").bootstrapTable 'refresh', {silent: true}
  $("#participant-info").bootstrapTable 'refresh', {silent: true}

(exports ? this).visitSorter = (a, b) ->
  format = (string) -> 
    mdy_array = string.split('/')
    parseInt [mdy_array[2], mdy_array[0], mdy_array[1]].join('')

  if format(a) > format(b) then -1 else 1
