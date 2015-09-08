$ ->

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
    event.stopPropagation()

  $(document).on 'click', '.add_service', ->
    data =
      'appointment_id': $(this).parents('.row.appointment').data('id'),
      'service_id': $('#service_list').val(),
      'qty': $('#service_quantity').val()

    $.ajax
      type: 'POST'
      url:  "/procedures.js"
      data: data

  $(document).on 'click', '.start_visit', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}?field=start_date"
      success: ->
        # reload table of procedures, so that UI elements disabled
        # before start of appointment can be reenabled
        $.ajax
          type: 'GET'
          url: "/appointments/#{appointment_id}.js"

  $(document).on 'click', '.complete_visit', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    $.ajax
      type: 'PATCH'
      url:  "/appointments/#{appointment_id}?field=completed_date"

  $(document).on 'click', '.reset_visit', ->
    data = appointment_id: $(this).parents('.row.appointment').data('id')
    if confirm("Resetting this appointment will delete all data which has been recorded for this appointment, are you sure you wish to continue?")
      $.ajax
        type: 'PUT'
        url: "/multiple_procedures/reset_procedures.js"
        data: data


  # Procedure buttons

  $(document).on 'dp.hide', ".completed_date_field", ->
    procedure_id = $(this).parents(".procedure").data("id")
    completed_date = $(this).children("input").val()
    data = procedure:
            completed_date: completed_date
    $.ajax
      type: 'PUT'
      url: "/procedures/#{procedure_id}"
      data: data

  $(document).on 'dp.hide', ".followup_procedure_datepicker", ->
    task_id = $(this).children("input").data("taskId")
    due_at = $(this).children("input").val()
    data = task:
            due_at: due_at
    $.ajax
      type: 'PUT'
      url: "/tasks/#{task_id}"
      data: data

  $(document).on 'change', '.billing_type', ->
    procedure_id = $(this).parents('.procedure').data('id')
    billing_type = $(this).val()
    data = procedure:
           billing_type: billing_type
    $.ajax
      type: 'PUT'
      url: "/procedures/#{procedure_id}"
      data: data


  $(document).on 'click', 'label.status.complete', ->
    active        = $(this).hasClass('active')
    procedure_id  = $(this).parents('.procedure').data('id')
    if active
      # undo complete status
      $(this).removeClass('selected_before')
      $(".procedure[data-id='#{procedure_id}'] .completed_date_field input").val(null)
      $(".procedure[data-id='#{procedure_id}'] .performed-by .selectpicker").selectpicker('val', null)
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
      $(".procedure[data-id='#{procedure_id}'] .performed-by .selectpicker").selectpicker('val', null)
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

  $(document).on 'click', 'button.incomplete_all_button', ->
    data = status: "incomplete", core_id: $(this).data('core-id'), appointment_id: $(this).parents('div.row.appointment').data('id')
    $.ajax
      type: 'GET'
      data: data
      url: "/multiple_procedures/incomplete_all.js"

  $(document).on 'click', ".complete_all_button", ->
    data = status: "complete", core_id: $(this).data('core-id'), appointment_id: $(this).parents('div.row.appointment').data('id')
    $.ajax
      type: 'PUT'
      data: data
      url: "/multiple_procedures/update_procedures.js"

  $(document).on 'click', '#edit_modal .close_modal, #incomplete_modal .close_modal', ->
    id = $(this).parents('.modal-content').data('id')
    $("#incomplete_button_#{id}").parent().removeClass('active')
    if $("#complete_button_#{id}").parent().hasClass('selected_before')
      $("#complete_button_#{id}").parent().addClass('active')

  $(document).on 'click', 'button.appointment.new', ->
    participant_id = $(this).data('participant-id')
    arm_id = $(this).data('arm-id')

    data = custom_appointment: participant_id: participant_id, arm_id: arm_id

    $.ajax
      type: 'GET'
      data: data
      url: "/custom_appointments/new"

  $(document).on 'click', 'button.followup.new', ->
    procedure_id  = $(this).parents('.procedure').data('id')

    $.ajax
      type: 'GET'
      url: "/procedures/#{procedure_id}/edit.js"

  $(document).on 'click', '.procedure button.delete', ->
    procedure_id = $(this).parents(".procedure").data("id")

    if confirm('Are you sure you want to remove this procedure?')
      $.ajax
        type: 'DELETE'
        url:  "/procedures/#{procedure_id}.js"
        error: ->
          alert('This procedure has already been marked as complete, incomplete, or requiring a follow up and cannot be removed')

  $(document).on 'change', '#appointment_content_indications', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    contents = $(this).val()
    data = 'contents' : contents
    $.ajax
      type: 'PUT'
      data: data
      url:  "/appointments/#{appointment_id}"

  $(document).on 'change', '#appointment_indications', ->
    appointment_id = $(this).parents('.row.appointment').data('id')
    statuses = $(this).val()
    data = 'statuses'       : statuses

    $.ajax
      type: 'PUT'
      data: data
      url: "/appointments/#{appointment_id}/"

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
    $('#start_date').datetimepicker(defaultDate: date)
    $('#start_date').on 'dp.hide', (e) ->
      appointment_id = $(this).parents('.row.appointment').data('id')
      $.ajax
        type: 'PATCH'
        url:  "/appointments/#{appointment_id}?field=start_date&new_date=#{e.date}"
        success: ->
          if !$('.completed_date_input').hasClass('hidden')
            $('#completed_date').data("DateTimePicker").minDate(e.date)

  window.completed_date_init = (date) ->
    $('#completed_date').datetimepicker(defaultDate: date)
    $('#start_date').data("DateTimePicker").maxDate($('#completed_date').data("DateTimePicker").date())
    $('#completed_date').data("DateTimePicker").minDate($('#start_date').data("DateTimePicker").date())
    $('#completed_date').on 'dp.hide', (e) ->
      appointment_id = $(this).parents('.row.appointment').data('id')
      $.ajax
        type: 'PATCH'
        url:  "/appointments/#{appointment_id}?field=completed_date&new_date=#{e.date}"
        success: ->
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

  # Display a helpful message when user clicks on a disabled UI element
  $(document).on 'click', '.pre_start_disabled, .complete-all-container.contains_disabled, .incomplete-all-container.contains_disabled', ->
    alert(I18n["appointment"]["warning"])

  $(document).on 'click', '.completed_date_btn.contains_disabled', ->
    alert("After clicking Start Visit, please either complete, incomplete, or assign a follow up date for each procedure before completing visit.")
