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
  if $('#appointmentContainer').length
    $.ajax
      method: 'GET'
      dataType: 'script'
      url: $('.appointment-link.active').prop('href')

  # Allow the page to reload a previous appointment when navigating
  # with the browseer's "Back" arrow
  $(window).on 'popstate', ->
    url = new URL(window.location)
    appointmentId = url.searchParams.get('appointment_id')
    $('.appointment-link.active').removeClass('active')
    $(".appointment-link[data-appointment-id=#{appointmentId}]").addClass('active')
    $('#appointmentContainer').addClass('d-none')
    $('#appointmentLoadingContainer').removeClass('d-none')
    $.ajax
      method: 'GET'
      dataType: 'script'
      url: "/appointments/#{appointmentId}"

  $(document).on 'ajax:beforeSend', '.appointment-link', ->
    url = new URL(window.location)
    url.searchParams.set('appointment_id', $(this).data('appointment-id'))
    window.history.pushState({}, null, url.toString())
    $('.appointment-link.active').removeClass('active')
    $(this).addClass('active')
    $('#appointmentContainer').addClass('d-none')
    $('#appointmentLoadingContainer').removeClass('d-none')

  $(document).on 'click', '.complete-appointment:not(.disabled)', ->
    start_date = new Date(parseInt(moment($('#start_date').data("date"), "MM/DD/YYYY h:mm a").format('x')))
    end_date = new Date($.now())

    if start_date > end_date
      data = field: "completed_date", appointment: completed_date: start_date.toUTCString()
    else
      data = field: "completed_date", appointment: completed_date: end_date.toUTCString()

    url = $(this).data('url')
    $.ajax
      type: 'PUT'
      data: data
      url:  url








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

  $(document).on 'click', '.add_service', ->
    if $('#service_list').val() == ''
      $('.service-error').removeClass('hidden')
    else
      $('.service-error').addClass('hidden')
      data =
        'appointment_id': $(this).parents('.row.appointment').data('id'),
        'service_id': $('#service_list').val(),
        'qty': $('#service_quantity').val()

      $.ajax
        type: 'POST'
        url:  "/procedures.js"
        data: data

      $('#service_list').val('').trigger('change')

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

  $(document).on 'change', '.billing_type.bootstrap-select', ->
    procedure    = $(this).parents('tr.procedure')
    procedure_id = $(procedure).data('id')
    original_group_id = $(procedure).data('group-id')
    billing_type = $(this).children('.selectpicker').find("option:selected").val()
    data = procedure:
           billing_type: billing_type
    $.ajax
      type: 'PUT'
      url: "/procedures/#{procedure_id}.js"
      data: data

  $(document).on 'click', 'label.status.complete', ->
    if !$(this).hasClass('disabled')
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
    unless $(this).hasClass('disabled')
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

  $(document).on 'click', 'button.complete-all, button.incomplete-all', ->
    status = $(this).data('status')
    select = $(this).parents('.service-multiselect-container').find('select.core_multiselect')
    appointment_id = select.attr('data-appointment-id')
    procedure_ids = fetch_multiselect_group_ids(select)

    if procedure_ids.length > 0
      $.ajax
        type: 'GET'
        data:
          status: status
          procedure_ids: procedure_ids
        url: "/appointments/#{appointment_id}/multiple_procedures/#{status}_all.js"
        success: ->
          select.selectpicker('deselectAll')

  $(document).on 'click', '#edit_modal .close_modal, #incomplete_modal .close_modal', ->
    id = $(this).parents('.modal-content').data('id')
    $("#incomplete_button_#{id}").parent().removeClass('active')
    if $("#complete_button_#{id}").parent().hasClass('selected_before')
      $("#complete_button_#{id}").parent().addClass('active')

  #Enables/Disables Complete and Incomplete buttons upon selecting services/deselecting services
  $(document).on 'change', "label.checkbox input[type='checkbox']", ->
    all_unchecked = !$(this).closest('.multiselect-container').find('li.active').length
    $(this).closest('.align-select-menu').find('.complete-all, .incomplete-all').toggleClass('disabled', all_unchecked)

  $(document).on 'click', 'button.appointment.new', ->
    protocols_participant_id = $(this).data('protocols-participant-id')
    arm_id = $(this).data('arm-id')

    data = custom_appointment: arm_id: arm_id, protocols_participant_id: protocols_participant_id

    $.ajax
      type: 'GET'
      data: data
      url: "/custom_appointments/new.js"

  $(document).on 'click', 'button.followup.new', ->
    if !$(this).hasClass('disabled')
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

  $(document).on 'change change.datetimepicker', '#appointmentStartDatePicker, #appointmentCompletedDatePicker', (e) ->
    datepicker_input = $(this).find('input')
    default_date = $(this).data('default-date')
    current_date = datepicker_input.val()

    if default_date != current_date
      appointment_id = $(this).data('appointment-id')
      datepicker = $(this)

      if datepicker_input.attr('name') == 'start_date'
        date_data = start_date: new Date(current_date).toUTCString()
      else
        date_data = completed_date: new Date(current_date).toUTCString()

      $.ajax
        type: 'PUT'
        data:
          appointment:
            date_data
        url: "/appointments/#{appointment_id}"

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

  window.fetch_multiselect_group_ids = (select) ->
    group_ids = select.val()
    procedure_ids = []

    if group_ids
      find_ids = (group_id) ->
        rows = $("td.name div[data-group-id='#{group_id}']")

        $.map rows, (row) ->
          procedure_ids.push $(row).data('procedure-id')

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

  $(document).on 'click', '.invoiced_disabled, .complete-all-container.invoiced_disabled, .incomplete-all-container.invoiced_disabled', ->
    alert(I18n["appointment"]["procedure_invoiced_warning"])

  $(document).on 'focus', '.dropdown-toggle', (e) ->
    if $(this).parent().hasClass('disable-select-box')
      alert(I18n["appointment"]["procedure_invoiced_warning"])
      $(this).blur()

  $(document).on 'click', '.disabled-status.btn-group .btn.disabled ', (e) ->
    e.stopPropagation()
    alert(I18n["appointment"]["procedure_invoiced_warning"])
