$ ->

  $(document).on 'click', '.task-complete', ->
    task_id = $(this).attr('task_id')
    checked = $(this).val()
    console.log task_id
    console.log checked
    $.ajax
      type: "PUT'


