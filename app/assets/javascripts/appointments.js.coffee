# Copyright © 2011-2016 MUSC Foundation for Research Development~
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

  window.reset_multiselect_after_update = (element) ->
    multiselect = $(element).siblings('#core_multiselect')
    $(multiselect).multiselect('deselectAll', false)
    $(multiselect).multiselect('updateButtonText')
    $(element).closest('.align-select-menu').find('.complete_all, .incomplete_all').toggleClass('disabled')

  $(document).on 'click', 'tr.procedure-group button', ->
    core = $(this).closest('tr.core')
    pg = new ProcedureGrouper(core)
    group = $(this).parents('.procedure-group')
    group_id = $(group).data('group-id')
    groups = $('.procedure-group')

    if $(group).find('span.glyphicon').hasClass('glyphicon-chevron-right')
      pg.show_group(group_id)
      close_open_procedure_groups(groups, group_id)
    else
      pg.hide_group(group_id)

  $(document).on 'click', '.dashboard_link', ->
    if $(this).hasClass('active')
      $(this).removeClass('active')
      $(this).text("-- Show Dashboard --")
    else
      $(this).addClass('active')
      $(this).text("-- Hide Dashboard --")

    $('#dashboard').slideToggle()

  $(document).on 'change', '#appointment_select', (event) ->
    id = $(this).val()

    if id != "-1"
      $.ajax
        type: 'GET'
        url: "/appointments/#{id}.js"

  $(document).on 'click', '.add_service', ->
    data =
      'appointment_id': $(this).parents('.row.appointment').data('id'),
      'service_id': $('#service_list').val(),
      'qty': $('#service_quantity').val()

    $.ajax
      type: 'POST'
      url:  "/procedures.js"
      data: data
      success: ->
        new_rows    = $('tr.procedure.new_service')
        core        = $(new_rows).first().parents('.core')
        multiselect = $(core).find('select.core_multiselect')
        pg          = new ProcedureGrouper()

        pg.update_group_membership new_row for new_row in new_rows
        pg.initialize_multiselect(multiselect)

  $(document).on 'click', '.start_visit', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    data = field: "start_date", appointment: start_date: new Date($.now()).toUTCString()
    $.ajax
      type: 'PUT'
      data: data
      url:  "/appointments/#{appointment_id}.js"
      success: ->
        # reload table of procedures, so that UI elements disabled
        # before start of appointment can be reenabled
        $.ajax
          type: 'GET'
          data: data
          url: "/appointments/#{appointment_id}.js"

  $(document).on 'click', '.complete_visit', ->
    start_date = new Date(parseInt(moment($('#start_date').data("date"), "MM/DD/YYYY h:mm a").format('x')))
    end_date = new Date($.now())

    if start_date > end_date
      data = field: "completed_date", appointment: completed_date: start_date.toUTCString()
    else
      data = field: "completed_date", appointment: completed_date: end_date.toUTCString()

    appointment_id = $(this).parents('.row.appointment').data('id')
    $.ajax
      type: 'PUT'
      data: data
      url:  "/appointments/#{appointment_id}.js"

  $(document).on 'click', '.reset_visit', ->
    data = appointment_id: $(this).parents('.row.appointment').data('id')
    if confirm("Resetting this appointment will delete all data which has been recorded for this appointment, are you sure you wish to continue?")
      $.ajax
        type: 'PUT'
        url: "/multiple_procedures/reset_procedures.js"
        data: data

  $(document).on 'click', '.uncomplete_visit', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    data = field: "reset_completed_date", appointment: completed_date: null
    $.ajax
      type: 'PUT'
      data: data
      url: "/appointments/#{appointment_id}.js"
      success: ->
        # reload table of procedures, so that UI elements disabled
        # before start of appointment can be re-enabled
        $.ajax
          type: 'GET'
          url: "/appointments/#{appointment_id}.js"

  # Procedure buttons
  $(document).on 'dp.hide', ".completed_date_field", ->
    procedure_id = $(this).parents(".procedure").data("id")
    completed_date = $(this).val()
    data = procedure:
            completed_date: completed_date
    $.ajax
      type: 'PUT'
      url: "/procedures/#{procedure_id}.js"
      data: data

  $(document).on 'dp.hide', ".followup_procedure_datepicker", ->
    task_id = $(this).data("taskId")
    due_at = $(this).val()
    data = task:
            due_at: due_at
    $.ajax
      type: 'PUT'
      url: "/tasks/#{task_id}.js"
      data: data

  $(document).on 'change', '.billing_type', ->
    procedure    = $(this).parents('tr.procedure')
    procedure_id = $(procedure).data('id')
    original_group_id = $(procedure).data('group-id')
    billing_type = $(this).val()
    data = procedure:
           billing_type: billing_type
    $.ajax
      type: 'PUT'
      url: "/procedures/#{procedure_id}.js"
      data: data
      success: ->
        procedure    = $("tr.procedure[data-id='#{procedure_id}']")
        group_id     = $(procedure).data('group-id')
        pg           = new ProcedureGrouper()

        pg.update_group_membership(procedure, original_group_id)

  $(document).on 'click', 'label.status.complete', ->
    active        = $(this).hasClass('active')
    procedure_id  = $(this).parents('.procedure').data('id')
    if active
      # undo complete status
      $(this).removeClass('selected_before')
      $(".procedure[data-id='#{procedure_id}'] .completed_date_field input").val(null)
      data = procedure:
              status: "unstarted"
              performer_id: null
    else
      #Actually complete procedure
      $(this).addClass('selected_before')
      $(this).removeClass('inactive')
      data = procedure:
              status: "complete"
              performer_id: gon.current_identity_id

    $.ajax
      type: 'PUT'
      data: data
      url: "/procedures/#{procedure_id}.js"

  $(document).on 'click', 'label.status.incomplete', ->
    active        = $(this).hasClass('active')
    procedure_id  = $(this).parents('.procedure').data('id')
    # undo incomplete status
    if active
      data = procedure:
              status: "unstarted"
              performer_id: null

      $.ajax
        type: 'PUT'
        data: data
        url: "/procedures/#{procedure_id}.js"

    else
      data = partial: "incomplete", procedure: status: "incomplete"

      $.ajax
        type: 'GET'
        data: data
        url: "/procedures/#{procedure_id}/edit.js"

  $(document).on 'click', 'button.incomplete_all', ->
    status = 'incomplete'
    procedure_ids = fetch_multiselect_group_ids(this)
    self = this

    if procedure_ids.length > 0
      $.ajax
        type: 'GET'
        data:
          status: status
          procedure_ids: _.flatten(procedure_ids)
        url: "/multiple_procedures/incomplete_all.js"
        success: ->
          reset_multiselect_after_update(self)

  $(document).on 'click', 'button.complete_all', ->
    status = 'complete'
    procedure_ids = fetch_multiselect_group_ids(this)
    self = this

    if procedure_ids.length > 0
      $.ajax
        type: 'GET'
        data:
          status: status
          procedure_ids: _.flatten(procedure_ids)
        url: "/multiple_procedures/complete_all.js"
        success: ->
          reset_multiselect_after_update(self)

  $(document).on 'click', '#edit_modal .close_modal, #incomplete_modal .close_modal', ->
    id = $(this).parents('.modal-content').data('id')
    $("#incomplete_button_#{id}").parent().removeClass('active')
    if $("#complete_button_#{id}").parent().hasClass('selected_before')
      $("#complete_button_#{id}").parent().addClass('active')

  #Enables/Disables Complete and Incomplete buttons upon selecting services/deselecting services
  $(document).on 'change', "label.checkbox input[type='checkbox']", ->
    all_unchecked = !$(this).closest('.multiselect-container').find('li.active').length
    $(this).closest('.align-select-menu').find('.complete_all, .incomplete_all').toggleClass('disabled', all_unchecked)

  $(document).on 'click', 'button.appointment.new', ->
    participant_id = $(this).data('participant-id')
    arm_id = $(this).data('arm-id')

    data = custom_appointment: participant_id: participant_id, arm_id: arm_id

    $.ajax
      type: 'GET'
      data: data
      url: "/custom_appointments/new.js"

  $(document).on 'click', 'button.followup.new', ->
    procedure_id  = $(this).parents('.procedure').data('id')

    $.ajax
      type: 'GET'
      url: "/procedures/#{procedure_id}/edit.js"

  $(document).on 'click', '.procedure button.delete', ->
    element      = $(this).parents(".procedure")
    procedure_id = $(element).data("id")

    if confirm('Are you sure you want to remove this procedure?')
      $.ajax
        type: 'DELETE'
        url:  "/procedures/#{procedure_id}.js"
        error: ->
          alert('This procedure has already been marked as complete, incomplete, or requiring a follow up and cannot be removed')
        success: ->
          pg  = new ProcedureGrouper()
          row = $("tr.procedure[data-id='#{procedure_id}']")

          pg.destroy_row(row)

  $(document).on 'change', '#appointment_content_indications', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    contents = $(this).val()
    data = appointment: contents : contents
    $.ajax
      type: 'PUT'
      data: data
      url:  "/appointments/#{appointment_id}.js"

  $(document).on 'change', '#appointment_indications', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    statuses = $(this).val()
    data = 'statuses' : statuses

    $.ajax
      type: 'PUT'
      data: data
      url: "/appointments/#{appointment_id}/update_statuses.js"

  $(document).on 'change', 'td.performed-by .selectpicker', ->
    procedure_id = $(this).parents(".procedure").data("id")
    selected = $(this).find("option:selected").val()
    data = procedure:
              performer_id: selected
    $.ajax
      type: 'PUT'
      data: data
      url: "/procedures/#{procedure_id}.js"

  window.start_date_init = (date) ->
    $('#start_date').datetimepicker
      format: 'MM/DD/YYYY h:mm a'
      defaultDate: date
      ignoreReadonly: true
    $('#start_date').on 'dp.hide', (e) ->
      appointment_id = $(this).parents('.row.appointment').data('id')
      data = appointment: start_date: e.date.toDate().toUTCString()
      $.ajax
        type: 'PUT'
        data: data
        url:  "/appointments/#{appointment_id}.js"
        success: ->
          if !$('.completed_date_input').hasClass('hidden')
            $('#completed_date').data("DateTimePicker").minDate(e.date)

  window.completed_date_init = (date) ->
    $('#completed_date').datetimepicker
      format: 'MM/DD/YYYY h:mm a'
      defaultDate: date
      ignoreReadonly: true
    $('#start_date').data("DateTimePicker").maxDate($('#completed_date').data("DateTimePicker").date())
    $('#completed_date').data("DateTimePicker").minDate($('#start_date').data("DateTimePicker").date())
    $('#completed_date').on 'dp.hide', (e) ->
      appointment_id = $(this).parents('.row.appointment').data('id')
      data = appointment: completed_date: e.date.toDate().toUTCString()
      $.ajax
        type: 'PUT'
        data: data
        url:  "/appointments/#{appointment_id}.js"
        success: ->
          $('#completed-appointments-table').bootstrapTable('refresh', {silent: "true"})
          $('#start_date').data("DateTimePicker").maxDate(e.date)

  # If enable_it true, enable Complete Visit button; otherwise, disable it.
  # Also, add the contains_disabled class to the containing div whenever
  # the button is disabled.
  window.update_complete_visit_button = (enable_it) ->
    if enable_it
      $("button.complete_visit").removeClass('disabled')
      $("div.completed_date_btn").removeClass('contains_disabled')
    else
      $("button.complete_visit").addClass('disabled')
      $("div.completed_date_btn").addClass('contains_disabled')

  window.fetch_multiselect_group_ids = (element) ->
    multiselect = $(element).parents('.core').find('select.core_multiselect')
    group_ids = multiselect.val()
    procedure_ids = []

    if group_ids
      find_ids = (group_id) ->
        rows = $("tr.procedure[data-group-id='#{group_id}']")

        procedure_ids.push $.map rows, (row) ->
          $(row).data('id')

      find_ids group_id for group_id in group_ids

      return procedure_ids

  close_open_procedure_groups = (groups, group_id) ->
    groups.each ->
      if $(this).find('span.glyphicon').hasClass('glyphicon-chevron-down') && ($(this).data('group-id') != group_id)
        pg = new ProcedureGrouper($(this).closest('tr.core'))
        pg.hide_group($(this).data('group-id'))

  # Display a helpful message when user clicks on a disabled UI element
  $(document).on 'click', '.pre_start_disabled, .complete-all-container.contains_disabled, .incomplete-all-container.contains_disabled', ->
    alert(I18n["appointment"]["warning"])

  $(document).on 'click', '.completed_date_btn.contains_disabled', ->
    alert("After clicking Start Visit, please either complete, incomplete, or assign a follow up date for each procedure before completing visit.")
