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

  $(document).on 'load-success.bs.table', '#participants-tracker-table', ->
    tables_to_refresh = ['table.protocol_reports']
    
    $.each $('table.participants td.participant_report button'), (index, value) ->
      remote_document_generator value, tables_to_refresh

  $(document).on 'click', '.participant-calendar', ->
    protocol_id = $(this).attr('protocol_id')
    participant_id = $(this).attr('participant_id')
    window.location = "/participants/#{participant_id}"

  $(document).on 'click', '.change-arm', ->
    participant_id = $(this).attr('participant_id')
    data = arm_id : $(this).attr('arm_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/change_arm"
      data: data

  $(document).on 'change', '.participant_status', ->
    participant_id = $(this).data("id")
    status         = $(this).val()
    data = 'participant': 'status': status
    $.ajax
      type: "PUT"
      url: "/participants/#{participant_id}"
      data: data