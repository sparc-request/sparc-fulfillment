window.increment_notification = (documentable_type) ->
  $notification = get_notification documentable_type
  number_of_notifications = get_number_of_notifications $notification
  $notification.text(number_of_notifications + 1)

window.decrement_notification = (documentable_type) ->
  $notification = get_notification documentable_type
  number_of_notifications = get_number_of_notifications $notification
  $notification.text(number_of_notifications - 1) if number_of_notifications > 0

get_notification = (documentable_type) ->
  switch documentable_type
    when 'Protocol'
      $('.notification.report-notifications')
    when 'Identity'
      $('.notification.document-notifications')

get_number_of_notifications = (notification) ->
  number_of_notifications = parseInt(notification.text())
