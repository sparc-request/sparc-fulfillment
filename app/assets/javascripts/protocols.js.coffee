$ ->
  if $("body.protocols-index").length > 0

    # Delete Protocol tab-remembering cookie
    $.removeCookie("active-protocol-tab")

    #Setting the default state of the index page on initial load
    $('#protocol-list').bootstrapTable('hideColumn', 'start_date')
    $('#protocol-list').bootstrapTable('hideColumn', 'end_date')
    $('#protocol-list').bootstrapTable('hideColumn', 'study_cost')
    $('#protocol-list').bootstrapTable('hideColumn', 'stored_percent_subsidy')
    $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_committed')
    $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_expended')


    $(".bootstrap-table .fixed-table-toolbar").
      prepend('<div class="columns btn-group pull-right financial--view" data-toggle="buttons"><label class="btn btn-default financial" title="Financial View"><input type="radio" autocomplete="off" value="financial"><i class="glyphicon glyphicon-usd"></i></label><label class="btn btn-default management" title="Management View"><input type="radio" autocomplete="off" value="management"><i class="glyphicon glyphicon-book"></i></label></div>')

    $(".financial-management-view label").on "click", ->
      e = $(this)

    $('table.protocols').on 'click', 'td:not(td.coordinators)', ->
      id = $(this).parent().find("td.sparc_id").text()

      window.location = "/protocols/#{id}"

    # if $("body.particpanttracker-particpant_tracker").length >= 0
      #insert edit excel spreadsheet and delete buttons here


    # $('#protocol-list').on 'search.bs.table', (e, text) ->
    #   if text == ''
    #     status = $('.selectpicker').val()
    #     $('#protocol-list').bootstrapTable('refresh', {url: "/protocols/protocols_by_status.json?status=" + status})
    #   else
    #     $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json"})

    #Index table events
    $(document).on 'change', '#index_selectpicker', ->
      status = $(this).val()
      $('#protocol-list').bootstrapTable('refresh', {url: "/protocols.json?status=" + status, silent: "true"})

    $(document).on 'click', '.financial', ->
      $('#protocol-list').removeClass('custom_striped')
      $('#protocol-list').addClass('custom_striped_financial')
      $('#protocol-list').bootstrapTable('hideColumn', 'updates')
      $('#protocol-list').bootstrapTable('hideColumn', 'status')
      $('#protocol-list').bootstrapTable('hideColumn', 'short_title')
      $('#protocol-list').bootstrapTable('hideColumn', 'coordinators')
      $('#protocol-list').bootstrapTable('hideColumn', 'irb_approval_date')
      $('#protocol-list').bootstrapTable('showColumn', 'start_date')
      $('#protocol-list').bootstrapTable('showColumn', 'end_date')
      $('#protocol-list').bootstrapTable('showColumn', 'study_cost')
      $('#protocol-list').bootstrapTable('showColumn', 'stored_percent_subsidy')
      $('#protocol-list').bootstrapTable('showColumn', 'subsidy_committed')
      $('#protocol-list').bootstrapTable('showColumn', 'subsidy_expended')

    $(document).on 'click', '.management', ->
      $('#protocol-list').addClass('custom_striped')
      $('#protocol-list').removeClass('custom_striped_financial')
      $('#protocol-list').bootstrapTable('showColumn', 'updates')
      $('#protocol-list').bootstrapTable('showColumn', 'status')
      $('#protocol-list').bootstrapTable('showColumn', 'short_title')
      $('#protocol-list').bootstrapTable('showColumn', 'coordinators')
      $('#protocol-list').bootstrapTable('showColumn', 'irb_approval_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'start_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'end_date')
      $('#protocol-list').bootstrapTable('hideColumn', 'study_cost')
      $('#protocol-list').bootstrapTable('hideColumn', 'stored_percent_subsidy')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_committed')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_expended')

  if $("body.protocols-show").length > 0
    current_tab = $.cookie("active-protocol-tab")

    if current_tab && current_tab.length > 0
      $(".nav-tabs a[href='##{current_tab}']").tab('show')

    $('a[data-toggle="tab"]').on 'shown.bs.tab', (e) ->
      tab = String(e.target).split("#")[1]
      $.cookie("active-protocol-tab", tab, expires: 1, path: '/')

(exports ? this).number_to_percent = (value) ->
  value + '%'
