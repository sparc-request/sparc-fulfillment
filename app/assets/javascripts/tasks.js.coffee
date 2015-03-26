$ ->
  $('[data-toggle="tooltip"]').tooltip()

  $(document).on 'click', 'table.tasks tbody td:not(td.complete, td.reschedule)', ->
    row_id  = $(this).parents("tr").attr("data-index")
    task_id = $(this).parents("table").bootstrapTable("getData")[row_id].id

    $.ajax
      type: 'GET'
      url: "/tasks/#{task_id}.js"

  $(document).on 'click', '.task-complete', ->
    task_id = $(this).attr('task_id')
    data = 'task': 'complete' : 'true'
    $.ajax
      type: 'PUT'
      url: "/tasks/#{task_id}.js"
      data: data
      success: ->
        $('#task-list').bootstrapTable('refresh', {url: "/tasks.json", silent: "true"})

  $(document).on 'click', '.task-reschedule', ->
    task_id = $(this).attr('task_id')
    $.ajax
      type: 'GET'
      url: "/tasks/#{task_id}/task_reschedule"

  - if $("body.tasks-index").length > 0
    $("table.tasks").bootstrapTable('hideColumn', 'id')
