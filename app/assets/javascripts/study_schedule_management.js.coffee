$ ->

    $(document).on 'click', '#add_arm_button', ->
      data =
        "protocol_id" : $('#arms').data('protocol_id')
        "schedule_tab" : $('#current_tab').attr('value')
      $.ajax
        type: 'GET'
        url: "/arms/new"
        data: data

    $(document).on 'click', '#remove_arm_button', ->
      # Ensure there are at least two arms in dropdown
      # so that protocol always has at least one arm.
      # Arms are deleted through a delayed job, so
      # we need the count from the dropdown and not
      # the server.
      if $("#arms > option").size() > 1
        protocol_id = $('#arms').data('protocol_id')
        arm_id = $("#arms").val()
        del = confirm "Are you sure you want to delete the selected arm from this protocol"
        if del
          $.ajax
            type: 'DELETE'
            url: "/arms/#{arm_id}?protocol_id=#{protocol_id}"
      else
        alert("Cannot remove the last Arm for this Protocol. All Protocols must have at least one Arm.")

    $(document).on 'click', '#add_visit_group_button', ->
      current_page = $(".visit_dropdown").first().attr('page')
      protocol_id = $('#arms').data('protocol_id')
      schedule_tab = $('#current_tab').attr('value')
      data =
        'current_page': current_page
        'schedule_tab': schedule_tab
        'protocol_id' : protocol_id
      $.ajax
        type: 'GET'
        url: "/visit_groups/new"
        data: data


    $(document).on 'click', '#edit_visit_group_button', ->
      visit_group_id = $('#visits').val()
      protocol_id = $('#arms').data('protocol_id')
      data =
        'protocol_id'    : protocol_id
        'visit_group_id' : visit_group_id
      $.ajax
        type: 'GET'
        url: "/visit_groups/#{visit_group_id}/edit"
        data: data

    $(document).on 'click', '#edit_arm_button', ->
      arm_id = $('#arms').val()
      data =
        'arm_id' : arm_id
      $.ajax
        type: 'GET'
        url: "/arms/#{arm_id}/edit"
        data: data

    $(document).on 'click', '#remove_visit_group_button', ->
      schedule_tab = $('#current_tab').attr('value')
      visit_group_id = $("#visits").val()
      arm_id = $('#arms').val()
      page = $("#visits_select_for_#{arm_id}").val()
      del = confirm "Are you sure you want to delete the selected visit from all particpants?"
      data =
        'page': page
        'schedule_tab': schedule_tab
      if del
        $.ajax
          type: 'DELETE'
          url: "/visit_groups/#{visit_group_id}.js"
          data: data

    $(document).on 'click', '#add_service_button', ->
      schedule_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      data =
        'page_hash': page_hash
        'schedule_tab': schedule_tab
        'protocol_id': protocol_id
        'service_id': service_id
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/new_line_items"
        data: data

    $(document).on 'click', '#remove_service_button', ->
      schedule_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      data =
        'page_hash': page_hash
        'schedule_tab': schedule_tab
        'protocol_id': protocol_id
        'service_id': service_id
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/edit_line_items"
        data: data

    $(document).on 'change', "#service_id", ->
      if $('#header_text').val() == 'Remove Services'
        service_id = $(this).find('option:selected').val()
        change_service service_id

    $(document).on 'change', '#visit_group_arm_id', ->
      arm_id = $(this).find('option:selected').val()
      update_visit_group_form_page(arm_id)
      data =
        'arm_id': arm_id
      $.ajax
        type: 'GET'
        url: '/visit_groups/update_positions_on_arm_change'
        data: data

(exports ? this).update_visit_group_form_page = (arm_id) ->
  page = $("#visits_select_for_#{arm_id}").val()
  $("#current_page").val(page)

(exports ? this).change_service = (service_id) ->
  protocol_id = $('#arms').data('protocol_id')
  data =
    'protocol_id': protocol_id
    'service_id': service_id
  $.ajax
    type: 'GET'
    url: "/multiple_line_items/necessary_arms"
    data: data

(exports ? this).create_arm = (name, id) ->
  $select = $('#arms')
  $select.append('<option value=' + id + '>' + name + '</option>')
  $select.selectpicker('refresh')

(exports ? this).edit_arm_name = (name, id) ->
  $("#arms option[value=#{id}]").text("#{name}")
  $("#arms").selectpicker('refresh')
  $("#arm-name-display-#{id}").html("#{name}");

(exports ? this).edit_visit_group_name = (name, id) ->
  $(".visit_dropdown option[value=#{id}]").text("- #{name}") #update page dropdown
  $(".visit_dropdown").selectpicker('refresh')
  $("#visits option[value=#{id}]").text("#{name}") #update manage visits dropdown
  $("#visits").selectpicker('refresh')
  $("#visit_group_#{id}").val("#{name}")

(exports ? this).remove_arm = (arm_id) ->
  $select = $('#arms')
  $select.find("[value=#{arm_id}]").remove()
  $select.selectpicker('refresh')
  $(".study_schedule.service.arm_#{arm_id}").remove()

(exports ? this).remove_visit_group = (visit_group_id) ->
  $select = $('#visits')
  $select.find("[value=#{visit_group_id}]").remove()
  $select.selectpicker('refresh')
  $(".study_schedule.service.visit_group_#{visit_group_id}").remove()

