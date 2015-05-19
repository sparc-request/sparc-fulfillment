$ ->

  $('[data-toggle="tooltip"]').tooltip()

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
    if checked == false
      $('#complete').text("Show Complete")
      $('#complete').prop('value', 'true')

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


    $(document).on "click", "#complete", ->
      show_complete = $(this).prop('value')
    
      if show_complete == 'true'
        $(this).text("Show Incomplete")
        $(this).prop('value', 'false')
      else
        $(this).text("Show Complete")
        $(this).prop('value', 'true')
      $('#task-list').bootstrapTable('refresh', {url: "/tasks.json?complete=" + show_complete, silent: "true"})

    $(document).on 'click', "#all_tasks", ->
      show_tasks = $(this).prop('value')
      if show_tasks == 'true'
        $(this).text('Show My Tasks')
        $(this).prop('value', 'false')
      else
        $(this).text('Show All Tasks')
        $(this).prop('value', 'true')
      $('#task-list').bootstrapTable('refresh', {url: "/tasks.json?show_tasks=" + show_tasks, silent: "true"})


