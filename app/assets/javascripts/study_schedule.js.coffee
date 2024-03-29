# Copyright © 2011-2023 MUSC Foundation for Research Development~
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

  # Use cookie to remember study schedule tab
  $('.schedule-tab > a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
    tab = String(e.target).split("#")[1]
    date = new Date()
    date.setTime(date.getTime() + (60 * 60 * 1000))
    $.cookie("active-schedule-tab", tab, {expires: date}, path: '/') # save tab to cookie

  $(document).on 'click', '.page_change_arrow:not(.disabled)', ->
    data =
      'arm_id': $(this).data('arm-id'),
      'page'  : $(this).attr('page'),
      'tab'   : $('#current_tab').val()
    $.ajax
      type: 'GET'
      url:  '/study_schedule/change_page'
      data: data

  $(document).on 'change', '.visit_dropdown.selectpicker', ->
    page_selected = $(this).find('option:selected').attr('page')
    current_page = $(this).attr('page')
    tab = $('#current_tab').val()

    # Early out when selecting a visit that is already shown
    if page_selected == current_page
      $(this).selectpicker('val', page_selected)
      return

    data =
      'arm_id': $(this).data('arm-id')
      'page'  : page_selected
      'tab'   : tab
    $.ajax
      type: 'GET'
      url:  '/study_schedule/change_page'
      data: data

  $(document).on 'click', '#studyScheduleTabs a.nav-link', ->
    protocol_id = $(this).data('protocol')
    tab = $(this).data('tab')
    $('#current_tab').val(tab)
    arms_and_pages = {}

    $('.visit_dropdown.selectpicker').each ->
      page = $(this).val()

      arm_id = $(this).data('arm-id')
      arms_and_pages[arm_id] = page

    data =
      'arms_and_pages': arms_and_pages,
      'tab'   : tab
      'protocol_id' : protocol_id
    $.ajax
      type: 'GET'
      url:  '/study_schedule/change_tab'
      data: data

  $(document).on 'change', '.visit-quantity', ->
    checkbox = $(this)
    line_item_id = checkbox.parent().data('line-item-id')
    visit_group_id = checkbox.parent().data('visit-group-id')
    visit_id = checkbox.val()
    research = + checkbox.prop('checked') # unary operator '+' evaluates true/false to num
    data = 'visit':
      'research_billing_qty':  research,
      'insurance_billing_qty': 0,
      'effort_billing_qty': 0
    $.ajax
      type: 'PUT'
      url:  "/visits/#{visit_id}"
      data: data
      success: =>
        verify_row_button_state(line_item_id)
        verify_column_button_state(visit_group_id)


  $(document).on 'change', '.quantity', ->
    visit_id = $(this).attr('visit_id')
    quantity = $(this).val()
    qty_type = $(this).attr('qty_type')

    data = 'visit':
      "#{qty_type}": quantity
    $.ajax
      type: 'PUT'
      url:  "/visits/#{visit_id}"
      data: data

  $(document).on 'click', 'td.visit.quantity-visit', ->
    if $link = $(this).find('a:not(.disabled)')
      $.ajax
        method: $link.data('method') || 'GET'
        dataType: 'script'
        url: $link.attr('href')

  $(document).on 'change', '.visit-name', ->
    visit_group_id = $(this).data('visit-group-id')
    page = $(this).closest("table").find(".visit_dropdown.selectpicker").attr('page')
    name = $(this).val()
    tab = $('#current_tab').val()
    data =
      current_page: page,
      schedule_tab: tab,
      on_page_edit: true,
      visit_group:
        name: name
    $.ajax
      type: 'PUT'
      url:  "/visit_groups/#{visit_group_id}"
      data: data

  $(document).on 'click', '.check-row', ->
    if confirm("This will reset custom values for this row, do you wish to continue?")
      check = $(this).attr('check')
      line_item_id = $(this).data('line-item-id')
      arm_container = $(this).parents('.study-schedule-arm-container')
      data =
        'line_item_id': line_item_id,
        'check':        check
      $.ajax
        type: 'PUT'
        url:  '/study_schedule/check_row'
        data: data
        success: =>
          # Check off visits
          # Update text fields
          identifier = ".visit_for_line_item_#{line_item_id}"
          if check == 'true'
            check_row_column($(this), identifier, 'btn-success', 'btn-danger', 'false', I18n.t('visit.uncheck_row'), true, 1, 0)
          else
            check_row_column($(this), identifier, 'btn-danger', 'btn-success', 'true', I18n.t('visit.check_row'), false, 0, 0)

          #Check all column buttons
          $(arm_container).find('button.check-column').each () ->
            visit_group_id = $(this).data('visit-group-id')
            verify_column_button_state(visit_group_id)

  $(document).on 'click', '.check-column', ->
    if confirm("This will reset custom values for this column, do you wish to continue?")
      check = $(this).attr('check')
      visit_group_id = $(this).data('visit-group-id')
      arm_container = $(this).parents('.study-schedule-arm-container')
      data =
        'visit_group_id': visit_group_id,
        'check':        check
      $.ajax
        type: 'PUT'
        url:  '/study_schedule/check_column'
        data: data
        success: =>
          # Check off visits
          # Update text fields
          identifier = ".visit_for_visit_group_#{visit_group_id}"
          if check == 'true'
            check_row_column($(this), identifier, 'btn-success', 'btn-danger', 'false', I18n.t('visit.uncheck_column'), true, 1, 0)
          else
            check_row_column($(this), identifier, 'btn-danger', 'btn-success', 'true', I18n.t('visit.check_column'), false, 0, 0)

          #Check all row buttons
          $(arm_container).find("tr.line-item").each () ->
            line_item_id = $(this).data('line-item-id')
            verify_row_button_state(line_item_id)

  check_row_column = (obj, identifier, remove_class, add_class, attr_check, attr_title, prop_check, research_val, insurance_val) ->
    modify_check_button(obj, remove_class, add_class, attr_check, attr_title)
    $("#{identifier} input[type=checkbox]").prop('checked', prop_check)
    $("#{identifier} input[type=text].research").val(research_val)
    $("#{identifier} input[type=text].insurance").val(insurance_val)

  modify_check_button = (obj, remove_class, add_class, attr_check, attr_title) ->
    obj.removeClass(remove_class).addClass(add_class)
    obj.attr('check', attr_check)
    obj.attr('title', attr_title)

    if attr_check == 'true'
      obj.find('i.fa-times').addClass('d-none')
      obj.find('i.fa-check').removeClass('d-none')
    else
      obj.find('i.fa-check').addClass('d-none')
      obj.find('i.fa-times').removeClass('d-none')

    obj.tooltip('dispose')
    obj.tooltip()

  verify_column_button_state = (visit_group_id) ->
    checkboxes =    $(".visit_for_visit_group_#{visit_group_id} input[type=checkbox]")
    checked_boxes = checkboxes.filter( ->
                      $(this).prop('checked')
                    )
    column_button = $("button.check-column[data-visit-group-id=#{visit_group_id}]")

    if checked_boxes.length == checkboxes.length
      modify_check_button(column_button, 'btn-success', 'btn-danger', 'false', I18n.t('visit.uncheck_row'))
    else
      modify_check_button(column_button, 'btn-danger', 'btn-success', 'true', I18n.t('visit.check_row'))

  verify_row_button_state = (line_item_id) ->
    checkboxes =    $("tr#line_item_#{line_item_id} input[type=checkbox]")
    checked_boxes = checkboxes.filter( ->
                      $(this).prop('checked')
                    )
    row_button =    $("tr#line_item_#{line_item_id} button.check-row")

    if checked_boxes.length == checkboxes.length
      modify_check_button(row_button, 'btn-success', 'btn-danger', 'false', I18n.t('visit.uncheck_column'))
    else
      modify_check_button(row_button, 'btn-danger', 'btn-success', 'true', I18n.t('visit.check_column'))

(exports ? this).adjustCalendarHeaders = () ->
  zIndex = $('.study-schedule-arm-container').length * 5

  $('.study-schedule-arm-container').each ->
    $head   = $(this).children('.card-header')
    $row1   = $(this).find('.study-schedule-table > thead > tr:first-child')
    $row2   = $(this).find('.study-schedule-table > thead > tr:nth-child(2)')
    $row3   = $(this).find('.study-schedule-table > thead > tr:nth-child(3)')

    headHeight  = $head.outerHeight()
    row1Height  = $row1.outerHeight()
    row2Height  = $row2.outerHeight()
    row3Height  = $row3.outerHeight()

    $head.css('z-index': zIndex)
    zIndex -= 2
    $row1.children('th').css({ 'top': headHeight, 'z-index': zIndex })
    $row1.children('th.visit-group-select').css({ 'z-index': zIndex + 1 })
    zIndex--
    $row2.children('th').css({ 'top': headHeight + row1Height, 'z-index': zIndex })
    zIndex--
    $row3.children('th').css({ 'top': headHeight +  row1Height + row2Height, 'z-index': zIndex })
    zIndex--
