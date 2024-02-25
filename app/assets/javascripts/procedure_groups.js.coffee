$ ->
  $(document).on 'hide.datetimepicker', '.procedure-group-start-time, .procedure-group-end-time', ->
    Rails.fire($(this).parents('form')[0], 'submit')
