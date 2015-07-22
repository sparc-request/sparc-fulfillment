$ ->
    $(document).on 'click', '.edit-document', ->
      document_id = $(this).attr('document_id')
      $.ajax
        type: 'GET'
        url: "/documents/#{document_id}/edit"


  if $("body.documents-index").length > 0

    $(document).on 'click', '.report-buttons button', ->
      title = $(this).data("title")

      $.ajax
        type: 'GET'
        url: "/reports/new.js"
        data: title: title
        success: (data) ->
          increment_notification('Identity')

    $(document).on 'click', '.modal button.submit', (event) ->
      event.preventDefault()

      # validate form
      $form_groups = $(".modal .form-group")
      error_message = ""
      $form_groups.each ->
        $form_group = $(this)

        if $form_group.find(':input').val() == null || $form_group.find(':input').val().length == 0
          label = $form_group.find('label').text()
          if $form_group.find(':input').attr('type') == 'text'
            error_message = label + ' cannot be blank'
            return false

      if error_message.length > 0
        $(".modal #modal_errors").empty().append("<div class='alert alert-danger'>#{error_message}</div>")
      else
        $('.modal form').submit()

    $(document).on 'click', 'a.attached_file', ->
      update_view_on_download_new_report $(this), 'table.documents', 'Identity'
      
window.update_view_on_download_new_report = (element, table_to_update, documentable_type) ->
  row_index = element.parents().eq(1).attr("data-index")

  date_downloaded_element = element.parent().siblings("td.downloaded_at")
  
  if date_downloaded_element.text().length == 0
    decrement_notification(documentable_type)
    
    dNow = new Date
    MM   = if dNow.getMonth()+1  < 10 then '0'+(dNow.getMonth()+1) else dNow.getMonth()+1
    dd   = if dNow.getDate()     < 10 then '0'+dNow.getDate()      else dNow.getDate()
    yyyy =    dNow.getFullYear()
    hh   = if dNow.getHours()    < 10 then '0'+(dNow.getHours())   else dNow.getHours()
    mm   = if dNow.getMinutes()  < 10 then '0'+(dNow.getMinutes()) else dNow.getMinutes()
    ss   = if dNow.getSeconds()  < 10 then '0'+(dNow.getSeconds()) else dNow.getSeconds()
    utcdate = "#{MM}/#{dd}/#{yyyy} #{hh}:#{mm}:#{ss}"
    
    $(table_to_update).bootstrapTable 'updateCell', 
      rowIndex: row_index
      fieldName: 'downloaded_at'
      fieldValue: utcdate
