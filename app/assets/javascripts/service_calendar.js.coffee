# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$ ->
  change_page = (obj) ->
    data =
      'arm_id': obj.data('arm_id'),
      'page'  : obj.attr('page'),
      'tab'   : $('#current_tab').val()
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_page'
      data: data

  $(document).on 'click', '.page_change_arrow', ->
    change_page $(this)

  $(document).on 'change', '.visit_dropdown', ->
    page = $(this).find('option:selected').attr('parent_page')
    cur_page = $(this).attr('page')
    tab = $('#current_tab').val()
    if page == undefined || page == false
      page = $(this).val()

    # Early out when selecting a visit that is already shown
    if page == cur_page
      $(this).val(page)
      return

    data =
      'arm_id': $(this).data('arm_id')
      'page'  : page
      'tab'   : tab
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_page'
      data: data

  $(document).on 'click', '#service_calendar_tabs a', ->
    tab = $(this).data('tab')
    $('#current_tab').val(tab)
    arms_and_pages = {}

    $('.visit_dropdown.selectpicker').each ->
      page = $(this).val()

      arm_id = $(this).data('arm_id')
      arms_and_pages[arm_id] = page

    data =
      'arms_and_pages': arms_and_pages,
      'tab'   : tab
    $.ajax
      type: 'GET'
      url:  '/service_calendar/change_tab'
      data: data

    update_r_t_labels()

  $(document).on 'change', '.visit', ->
    data =
      'visit_id': $(this).val()
      'checked':  $(this).prop('checked')
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_visit'
      data: data

  # Add a tooltip to elt (e.g., "#visits_219_insurance_billing_qty")
  # containing content, which disappears when user focuses to it.
  window.error_tooltip_on = (elt, content) ->
    $elt = $(elt)
    $elt.attr('data-toggle', 'tooltip').attr('title', content)
    $elt.tooltip({container: 'body'})
    $elt.tooltip('show')
    delay = (ms, func) -> setTimeout func, ms
    delay 3000, -> $elt.tooltip('destroy')

  $(document).on 'change', '.quantity', ->
    visit_id = $(this).attr('visit_id')
    quantity = $(this).val()
    qty_type = $(this).attr('qty_type')

    if quantity == ''
      $(this).val($(this).attr('previous_qty'))
      return

    data =
      'visit_id': visit_id,
      'quantity': quantity,
      'qty_type': qty_type
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/change_quantity'
      data: data
      success: =>
        $(this).attr('previous_qty', quantity)

  $(document).on 'change', '.visit_name', ->
    visit_group_id = $(this).data('visit_group_id')
    name = $(this).val()
    data =
      'visit_group_id': visit_group_id,
      'name':           name
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/change_visit_name'
      data: data
      success: ->
        # Need to find out if this is actually necessary
        # or if we can use faye

        $(".visit_dropdown option[value=#{visit_group_id}]").text("- #{name}")
        $(".visit_dropdown").selectpicker('refresh')

        $("#visits option[value=#{visit_group_id}]").text("#{name}")
        $("#visits").selectpicker('refresh')

  $(document).on 'click', '.change_line_item_service', ->
    data =
      'line_item_id': $(this).attr('line_item_id')
    $.ajax
      type: 'GET'
      url: '/service_calendar/edit_service'
      data: data

  check_row_column = (obj, identifier, remove_class, add_class, attr_check, prop_check, research_val, insurance_val) ->
    obj.removeClass(remove_class).addClass(add_class)
    obj.attr('check', attr_check)
    $("#{identifier} input[type=checkbox]").prop('checked', prop_check)
    $("#{identifier} input[type=text].research").val(research_val)
    $("#{identifier} input[type=text].insurance").val(insurance_val)

  $(document).on 'click', '.check_row', ->
    check = $(this).attr('check')
    line_item_id = $(this).data('line_item_id')
    data =
      'line_item_id': line_item_id,
      'check':        check
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_row'
      data: data
      success: =>
        # Check off visits
        # Update text fields
        identifier = ".visits_for_line_item_#{line_item_id}"
        if check == 'true'
          check_row_column($(this), identifier, 'glyphicon-ok', 'glyphicon-remove', 'false', true, 1, 0)
        else
          check_row_column($(this), identifier, 'glyphicon-remove', 'glyphicon-ok', 'true', false, 0, 0)

  $(document).on 'click', '.check_column', ->
    check = $(this).attr('check')
    visit_group_id = $(this).attr('visit_group_id')
    data =
      'visit_group_id': visit_group_id,
      'check':        check
    $.ajax
      type: 'PUT'
      url:  '/service_calendar/check_column'
      data: data
      success: =>
        # Check off visits
        # Update text fields
        identifier = ".visit_for_visit_group_#{visit_group_id}"
        if check == 'true'
          check_row_column($(this), identifier, 'glyphicon-ok', 'glyphicon-remove', 'false', true, 1, 0)
        else
          check_row_column($(this), identifier, 'glyphicon-remove', 'glyphicon-ok', 'true', false, 0, 0)

  (exports ? this).change_service = (service_id) ->
    protocol_id = $('#arms').data('protocol_id')
    data =
      'protocol_id': protocol_id
      'service_id': service_id
    $.ajax
      type: 'GET'
      url: "/multiple_line_items/necessary_arms"
      data: data

  # if the current tab is not Template, then place R T labels
  # above check visit columns
  window.update_r_t_labels = () ->
    # find active study schedule tab, and pull name
    # from data-tab attribute
    tab = $("#service_calendar_tabs li.active a").
      data('tab')

    if tab != "template"
      $(".r-label").text("R")
      $(".t-label").text("T")
    else
      $(".r-label").text("")
      $(".t-label").text("")

  # switch to previously selected tab (before page load)
  current_tab = $.cookie("active-protocol-tab")

  if current_tab && current_tab.length > 0
    $(".nav-tabs a[href='##{current_tab}']").click()
