$ ->
  id = $('#task_id').val()

  $.ajax
    type: 'GET'
    url: "/tasks/#{id}.js"