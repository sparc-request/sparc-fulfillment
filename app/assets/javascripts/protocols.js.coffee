$ ->

  if $("body.protocols-index").length > 0

    # Delete Protocol tab-remembering cookie
    $.removeCookie("active-protocol-tab")
    # Delete Study Schedule tab-remembering cookie
    $.removeCookie("active-schedule-tab")

    $(".bootstrap-table .fixed-table-toolbar").
      prepend('<div class="columns btn-group pull-right financial--view" data-toggle="buttons"><label class="btn btn-default financial" title="Financial View"><input type="radio" autocomplete="off" value="financial"><i class="glyphicon glyphicon-usd"></i></label><label class="btn btn-default management" title="Management View"><input type="radio" autocomplete="off" value="management"><i class="glyphicon glyphicon-book"></i></label></div>')

    $('table.protocols').on 'click', 'td:not(td.coordinators)', ->
      if $(this).find("div.card-view").length == 0
        row_index   = $(this).parents("tr").data("index")
        protocol_id = $(this).parents("table").bootstrapTable("getData")[row_index].id

        window.location = "/protocols/#{protocol_id}"

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
      $('#protocol-list').bootstrapTable('showColumn', 'total_at_approval')
      $('#protocol-list').bootstrapTable('showColumn', 'percent_subsidy')
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
      $('#protocol-list').bootstrapTable('hideColumn', 'total_at_approval')
      $('#protocol-list').bootstrapTable('hideColumn', 'percent_subsidy')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_committed')
      $('#protocol-list').bootstrapTable('hideColumn', 'subsidy_expended')

(exports ? this).number_to_percent = (value) ->
  value + '%'
