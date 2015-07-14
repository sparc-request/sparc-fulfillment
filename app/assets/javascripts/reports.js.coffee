window.download_new_report = (element, documentable_type) ->
  data_id = $(element).data("id")
  date_downloaded_element = $(this).parent().siblings("td.downloaded_at")
  if date_downloaded_element.text().length == 0
    decrement_notification(documentable_type)
    dNow = new Date
    utcdate = (if dNow.getMonth()+1 < 10 then '0'+(dNow.getMonth()+1) else dNow.getMonth()+1) + '/' + (if dNow.getDate() < 10 then '0'+dNow.getDate() else dNow.getDate()) + '/' + dNow.getFullYear()
    $.ajax
      url: "/documents/#{data_id}"
      type: "GET",
      dataType: 'binary',
      processData: false,
      complete: date_downloaded_element.text("#{utcdate}")
      