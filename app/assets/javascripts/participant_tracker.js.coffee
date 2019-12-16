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

$ ->

  ### SEARCH PARTICIPANTS ###
  $(document).on 'click', '.search-participants', ->
    $.ajax
      type: 'GET'
      url: "/participants/associate_participants_to_protocol.js"
      data: 'protocol_id' : $(this).data('protocol-id')

  ### *CALENDAR ### 
  $(document).on 'click', '.participant-calendar', ->
    protocols_participant_id = $(this).attr('protocols_participant_id')
    participant_id = $(this).attr('participant_id')
    protocol_id = $(this).attr('protocol_id')
    window.location = "/participants/calendar?protocols_participant_id=#{protocols_participant_id}&protocol_id=#{protocol_id}&participant_id=#{participant_id}"

  ### REPORT ###
  $(document).on 'load-success.bs.table', '#participant-tracker-table', ->
    tables_to_refresh = ['table.protocol_reports']
    
    $.each $('table.participants td.participant_report button'), (index, value) ->
      remote_document_generator value, tables_to_refresh

  ### *ASSIGN ARM ###
  $(document).on 'click', '.change-arm', ->
    participant_id = $(this).attr('participant_id')
    data = arm_id : $(this).attr('arm_id'), protocol_id: $(this).attr('protocol_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/change_arm"
      data: data

  ### *STATUS ###
  $(document).on 'change', '.protocols_participant_status.selectpicker', ->
    participant_id = $(this).data("id")
    protocol_id = $(this).data("protocol-id")
    status         = $(this).val()
    data = 'protocols_participant': {'status': status}, 'protocol_id': protocol_id
    $.ajax
      type: "PUT"
      url: "/participants/#{participant_id}/change_status"
      data: data

  ### *NOTES ###
  ### in global.js file ###

  ### *DETAILS ###
  $(document).on 'click', '.participant-details', ->
    participant_id = $(this).attr('participant_id')
    $.ajax
      type: 'GET'
      url: "/participants/#{participant_id}/details"

  ### *DELETE ###
  $(document).on 'click', '.remove-participant', ->
    participant_id = $(this).attr('participant_id')
    name = $(this).attr('participant_name')
    del = confirm "Are you sure you want to remove #{name} from the Participant List?"
    if del
      $.ajax
        type: 'PUT'
        url: "/participants/#{participant_id}/destroy_protocols_participant"
        data: 'protocol_id': $(this).attr('protocol_id')


  ### ASSOCIATE PARTICIPANTS ###
  $(document).on 'change', '.associate', ->
    data =
      'protocol_id': $(this).attr('protocol_id')
      'participant_id': $(this).attr('participant_id')
      'checked': $(this).is(':checked')

    $.ajax
      type: 'POST'
      url: "/participants/update_protocol_association"
      data: data

  ###### Custom Search Text #####
  $table = $('#participant_tracker .participants')
  $table.on 'post-body.bs.table', ->
    $search = $table.data('bootstrap.table').$toolbar.find('.search input')
    $search.attr 'placeholder', 'Search Existing'
    return
  return
