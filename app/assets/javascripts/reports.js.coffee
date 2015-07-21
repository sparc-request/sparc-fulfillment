window.update_view_on_download_new_report = (element, table_to_update, documentable_type) ->
  row_index = element.parents().eq(1).attr("data-index")

  date_downloaded_element = element.parent().siblings("td.downloaded_at")
  
  if date_downloaded_element.text().length == 0
    decrement_notification(documentable_type)
    
    dNow = new Date
    utcdate = (if dNow.getMonth()+1 < 10 then '0'+(dNow.getMonth()+1) else dNow.getMonth()+1) + '/' + (if dNow.getDate() < 10 then '0'+dNow.getDate() else dNow.getDate()) + '/' + dNow.getFullYear()
    
    $(table_to_update).bootstrapTable 'updateCell', 
      rowIndex: row_index
      fieldName: 'downloaded_at'
      fieldValue: utcdate
