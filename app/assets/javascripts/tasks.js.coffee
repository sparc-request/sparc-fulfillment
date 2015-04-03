$ ->

  $('[data-toggle="tooltip"]').tooltip()

  $(".bootstrap-table .fixed-table-toolbar").
    prepend('<div class="pull-right columns"><button type="button" class="btn btn-default complete" data-toggle="button" aria-pressed="false" autocomplete="off" title="Show completed"><i class="glyphicon glyphicon-unchecked"></i></button></div>')

  $(document).on 'click', 'table.tasks tbody td:not(td.complete, td.reschedule)', ->
    row_id  = $(this).parents("tr").attr("data-index")
    task_id = $(this).parents("table").bootstrapTable("getData")[row_id].id

    $.ajax
      type: 'GET'
      url: "/tasks/#{task_id}.js"

  $(document).on 'click', "input[type='checkbox'].complete", ->
    task_id = $(this).attr('task_id')
    checked = $(this).is(':checked')
    data    = 'task': 'complete' : checked

    $.ajax
      type: 'PUT'
      url: "/tasks/#{task_id}.js"
      data: data

  $(document).on 'click', '.task-reschedule', ->
    task_id = $(this).attr('task_id')

    $.ajax
      type: 'GET'
      url: "/tasks/#{task_id}/task_reschedule"

  - if $("body.tasks-index").length > 0

    $("table.tasks").bootstrapTable('hideColumn', 'id')

    $(document).on "load-success.bs.table", "table.tasks", ->
      $("table.tasks tbody input.complete:checked").parents("tr").toggle()

    $(document).on "click", "button.complete", ->
      $("table.tasks tbody tr").toggle()
