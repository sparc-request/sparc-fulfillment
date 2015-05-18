$ ->

    $(document).on 'click', '#add_arm_button', ->
      protocol_id = $('#arms').data('protocol_id')
      $.ajax
        type: 'GET'
        url: "/arms/new?protocol_id=#{protocol_id}"

    $(document).on 'click', '#remove_arm_button', ->
      protocol_id = $('#arms').data('protocol_id')
      arm_id = $("#arms").val()
      del = confirm "Are you sure you want to delete the selected arm from this protocol"
      if del
        $.ajax
          type: 'DELETE'
          url: "/arms/#{arm_id}?protocol_id=#{protocol_id}"

    $(document).on 'click', '#add_visit_button', ->
      calendar_tab = $('#current_tab').attr('value')
      arm_id = $('#arms').val()
      page = $("#visits_select_for_#{arm_id}").val()
      data =
        'arm_id': arm_id
        'page': page
        'calendar_tab': calendar_tab
      $.ajax
        type: 'GET'
        url: "/visit_groups/new"
        data: data

    $(document).on 'click', '#remove_visit_button', ->
      calendar_tab = $('#current_tab').attr('value')
      visit_group_id = $("#visits").val()
      arm_id = $('#arms').val()
      page = $("#visits_select_for_#{arm_id}").val()
      del = confirm "Are you sure you want to delete the selected visit from all particpants?"
      data =
        'page': page
        'calendar_tab': calendar_tab
      if del
        $.ajax
          type: 'DELETE'
          url: "/visit_groups/#{visit_group_id}.js"
          data: data

    $(document).on 'click', '#add_service_button', ->
      calendar_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      data =
        'page_hash': page_hash
        'calendar_tab': calendar_tab
        'protocol_id': protocol_id
        'service_id': service_id
      $.ajax
        type: 'GET'
        url: "/multiple_line_items/new_line_items"
        data: data

    $(document).on 'click', '#remove_service_button', ->
      calendar_tab = $('#current_tab').attr('value')
      page_hash = {}
      $(".visit_dropdown.form-control").each (index) ->
        key = $(this).data('arm_id')
        value = $(this).attr('page')
        page_hash[key] = value
      protocol_id = $('#arms').data('protocol_id')
      service_id = $('#services').val()
      data =
        'page_hash': page_hash
        'calendar_tab': calendar_tab
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

(exports ? this).remove_arm = (arm_id) ->
  $select = $('#arms')
  $select.find("[value=#{arm_id}]").remove()
  $select.selectpicker('refresh')
  $(".calendar.service.arm_#{arm_id}").remove()

