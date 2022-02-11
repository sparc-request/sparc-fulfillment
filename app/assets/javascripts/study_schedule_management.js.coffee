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

$ ->

##              **MANAGE ARMS**                     ##
  $(document).on 'click', '#removeArmButton', (e) ->
    # Ensure there are at least two arms in dropdown
    # so that protocol always has at least one arm.
    # Arms are deleted through a delayed job, so
    # we need the count from the dropdown and not
    # the server.
    arm_name = $(".bootstrap-select > button[data-id='arm_form_select']").attr('title')
    Swal.fire(
      title: "Are you sure?"
      text: "Are you sure you want to remove arm: #{arm_name} from this protocol?"
      icon: "warning"
    ).then (confirm_delete_arm) ->
      if confirm_delete_arm.isConfirmed
        if $("#arm_form_select > option").length < 1
          Swal.fire(
            title: "Error"
            text: "Cannot remove the last Arm for this Protocol. All Protocols must have at least one Arm."
            icon: "error"
            showConfirmButton: false
          ).then (result) ->
            if result.isDismissed
              $("#modalContainer").modal('hide')
        else
          Rails.fire($('#navigateArmForm')[0], 'submit')

  $(document).on 'change', "#arm_form_select", ->
    data =
      "protocol_id"     : $('#study_schedule_buttons').data('protocol-id')
      "intended_action" : $("#navigateArmFormBody").data("intended-action")
      "arm_id"          : $(this).val()
    $.ajax
      type: 'GET'
      url: "/arms/navigate"
      data: data

##          **MANAGE VISIT GROUPS**               ##
  $(document).on 'click', '#add_visit_group_button', ->
    data =
      'current_page': $("select.visit_dropdown").first().attr('page')
      'schedule_tab': $('#current_tab').attr('value')
      'protocol_id' : $('#study_schedule_buttons').data('protocol-id')
    $.ajax
      type: 'GET'
      url: "/visit_groups/new"
      data: data

  # Arm select on add visit group modal
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
      'current_page'    : $("select.visit_dropdown").first().attr('page')
      'schedule_tab'    : $('#current_tab').attr('value')
      'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
      'intended_action' : "edit"
    $.ajax
      type: 'GET'
      url: "/visit_groups/navigate"
      data: data

  $(document).on 'click', '#remove_visit_group_button', ->
    data =
      'current_page'    : $("select.visit_dropdown").first().attr('page')
      'schedule_tab'    : $('#current_tab').attr('value')
      'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
      'intended_action' : "destroy"
    $.ajax
      type: 'GET'
      url: "/visit_groups/navigate"
      data: data

  # Arm select on navigate (edit/destroy) visit group modal
  $(document).on 'change', "#visit_group_arm_form_select", ->
    arm_id = $(this).val()
    data =
      'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
      "intended_action" : $("#navigateVisitFormBody").data('intended-action')
      "arm_id"          : arm_id
      'current_page'    : $("select#visits_select_for_#{arm_id}").attr('page')
      'schedule_tab'    : $('#current_tab').attr('value')
    $.ajax
      type: 'GET'
      url: "/visit_groups/navigate"
      data: data

  # Visit group select on navigate (edit/destroy) visit group modal
  $(document).on 'change', "#visit_group_form_select", ->
    intended_action = $("#navigateVisitFormBody").data('intended-action')
    arm_id = $('#visit_group_arm_form_select').val()
    data =
      'protocol_id'     : $('#study_schedule_buttons').data('protocol-id')
      "intended_action" : intended_action
      "visit_group_id"  : $(this).val()
      'current_page'    : $("select#visits_select_for_#{arm_id}").attr('page')
      'schedule_tab'    : $('#current_tab').attr('value')
    $.ajax
      type: 'GET'
      url: "/visit_groups/navigate"
      data: data

  $(document).on 'click', '#removeVisitGroupButton', ->
    arm_name = $(".bootstrap-select > button[data-id='arm_form_select']").attr('title')
    Swal.fire(
      title: "Are you sure?"
      text: "Are you sure you want to delete the selected visit from all particpants?"
      icon: "warning"
    ).then (confirm_delete_arm) ->
      if confirm_delete_arm.isConfirmed
        Rails.fire($('#navigateVisitForm')[0], 'submit')

##          **MANAGE LINE ITEMS**               ##
  $(document).on 'click', '#add_service_button', ->
    page_hash = {}
    $(".visit_dropdown.form-control").each (index) ->
      key = $(this).data('arm-id')
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

  $(document).on 'click', '#add_first_service_button', ->
    page_hash = {}
    data =
      'page_hash'   : page_hash
      'schedule_tab': $('#current_tab').attr('value')
      'protocol_id' : $('#add_first_service_button').data('protocol-id')
      'first_line_item': true
    $.ajax
      type: 'GET'
      url: "/multiple_line_items/new_line_items"
      data: data

  $(document).on 'click', '#remove_service_button', ->
    $.ajax
      type: 'GET'
      url: "/multiple_line_items/edit_line_items"
      data: 'protocol_id': $('#study_schedule_buttons').data('protocol-id')
