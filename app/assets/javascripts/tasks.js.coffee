$ ->

  $('[data-toggle="tooltip"]').tooltip()

  $(document).on 'click', '.new-task', ->
    $.ajax
      type: 'GET'
      url: "/tasks/new.js"

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


    $(document).on "click", "#complete", ->
      scope = $(this).prop('value')
    
      if scope == 'complete'
        $(this).text("Show Incomplete")
        $(this).prop('value', 'incomplete')
      else
        $(this).text("Show Complete")
        $(this).prop('value', 'complete')
      $('#task-list').bootstrapTable('refresh', {url: "/tasks.json?scope=" + scope, silent: "true"})

    $(document).on 'click', "#all_tasks", ->
      scope = $(this).prop('value')

      if scope == 'all'
        $(this).text('Show My Tasks')
        $(this).prop('value', 'mine')
      else
        $(this).text('Show All Tasks')
        $(this).prop('value', 'all')
      $('#task-list').bootstrapTable('refresh', {url: "/tasks.json?scope=" + scope, silent: "true"})


