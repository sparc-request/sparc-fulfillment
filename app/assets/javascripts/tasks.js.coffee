$ ->

  $(document).on 'click', '.task-complete', ->
    task_id = $(this).attr('task_id')
    data = 'task': 'is_complete' : true
    $.ajax
      type: 'PATCH'
      url: "/tasks/#{task_id}"
      data: data
      success: ->
        $('#task-list').bootstrapTable('refresh', {url: "/tasks.json", silent: "true"})


