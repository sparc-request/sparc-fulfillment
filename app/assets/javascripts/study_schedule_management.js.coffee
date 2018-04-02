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

##              **BEGIN MANAGE ARMS**                     ##

  $(document).on 'click', '#add_arm_button', ->
    data =
      "protocol_id" : $('#study_schedule_buttons').data('protocol-id')
      "schedule_tab" : $('#current_tab').attr('value')
    $.ajax
      type: 'GET'
      url: "/arms/new"
      data: data

  $(document).on 'click', '#remove_arm_button', ->
    data =
      "protocol_id" : $('#study_schedule_buttons').data('protocol-id')
      "intended_action" : "destroy"
    $.ajax
      type: 'GET'
      url: "/arms/navigate"
      data: data

  $(document).on 'click', '#remove_arm_form_button', ->
    # Ensure there are at least two arms in dropdown
    # so that protocol always has at least one arm.
    # Arms are deleted through a delayed job, so
    # we need the count from the dropdown and not
    # the server.
    arm_select = $("#arm_form_select")
    if $("#arm_form_select > option").size() > 1
      arm_id = arm_select.val()
      arm_name = $(".bootstrap-select > button[data-id='arm_form_select']").attr('title')
      if confirm "Are you sure you want to remove arm: #{arm_name} from this protocol?"
        $.ajax
          type: 'DELETE'
          url: "/arms/#{arm_id}"
          data: "protocol_id" : $('#study_schedule_buttons').data('protocol-id')
    else
      alert("Cannot remove the last Arm for this Protocol. All Protocols must have at least one Arm.")

  $(document).on 'click', '#edit_arm_button', ->
    data =
      "protocol_id" : $('#study_schedule_buttons').data('protocol-id')
      "intended_action" : "edit"
    $.ajax
      type: 'GET'
      url: "/arms/navigate"
      data: data

  $(document).on 'change', "#arm_form_select", ->
    data =
      "protocol_id"     : $('#study_schedule_buttons').data('protocol-id')
      "intended_action" : $("#navigate_arm_form").data("intended-action")
      "arm_id"          : $(this).val()
    $.ajax
      type: 'GET'
      url: "/arms/navigate"
      data: data

##              **END MANAGE ARMS**                     ##
##          **BEGIN MANAGE VISIT GROUPS**               ##

  $(document).on 'click', '#add_visit_group_button', ->
    data =
      'current_page': $("select.visit_dropdown").first().attr('page')
      'schedule_tab': $('#current_tab').attr('value')
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
    $.ajax
      type: 'GET'
      url: "/visit_groups/new"
      data: data

  $(document).on 'change', '#visit_group_arm_id', ->
    arm_id = $(this).find('option:selected').val()
    data =
      'current_page': $("#visits_select_for_#{arm_id}").val()
      'schedule_tab': $('#current_tab').attr('value')
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
      'arm_id'      : arm_id
    $.ajax
      type: 'GET'
      url: "/visit_groups/new"
      data: data

  $(document).on 'click', '#edit_visit_group_button', ->
    data =
      'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
      'intended_action' : "edit"
    $.ajax
      type: 'GET'
      url: "/visit_groups/navigate"
      data: data

  $(document).on 'click', '#remove_visit_group_button', ->
    data =
      'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
      'intended_action' : "destroy"
    $.ajax
      type: 'GET'
      url: "/visit_groups/navigate"
      data: data

  $(document).on 'change', "#vg_form_arm_select", ->
    arm_id = $(this).val()
    data =
      'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
      "intended_action" : $("#navigate_visit_form").data('intended-action')
      "arm_id" : arm_id
    $.ajax
      type: 'GET'
      url: "/visit_groups/navigate"
      data: data

  $(document).on 'change', "#vg_form_select", ->
    intended_action = $("#navigate_visit_form").data('intended-action')
    if intended_action == "edit"
      data =
        'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
        "intended_action" : intended_action
        "visit_group_id"  : $(this).val()
      $.ajax
        type: 'GET'
        url: "/visit_groups/navigate"
        data: data

  $(document).on 'click', '#remove_visit_group_form_button', ->
    schedule_tab = $('#current_tab').attr('value')
    visit_group_id = $("#vg_form_select").val()
    arm_id = $('#vg_form_arm_select').val()
    page = $("#visits_select_for_#{arm_id}").val()
    data =
      'page': page
      'schedule_tab': schedule_tab
    if confirm "Are you sure you want to delete the selected visit from all particpants?"
      $.ajax
        type: 'DELETE'
        url: "/visit_groups/#{visit_group_id}.js"
        data: data

##          **END MANAGE VISIT GROUPS**               ##
##          **BEGIN MANAGE LINE ITEMS**               ##

  $(document).on 'click', '#add_service_button', ->
    page_hash = {}
    $(".visit_dropdown.form-control").each (index) ->
      key = $(this).data('arm_id')
      value = $(this).attr('page')
      page_hash[key] = value
    data =
      'page_hash'   : page_hash
      'schedule_tab': $('#current_tab').attr('value')
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
    $.ajax
      type: 'GET'
      url: "/multiple_line_items/new_line_items"
      data: data

  $(document).on 'click', '#remove_service_button', ->
    $.ajax
      type: 'GET'
      url: "/multiple_line_items/edit_line_items"
      data: 'protocol_id': $('#study_schedule_buttons').data('protocol-id')

  $(document).on 'change', "#remove_service_id", ->
    data =
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
      'service_id'  : $(this).find('option:selected').val()
    $.ajax
      type: 'GET'
      url: "/multiple_line_items/edit_line_items"
      data: data

##          **END MANAGE LINE ITEMS**               ##
