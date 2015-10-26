$ ->
    $(document).on 'click', '.edit-document', ->
      document_id = $(this).data('document_id')
      $.ajax
        type: 'GET'
        url: "/documents/#{document_id}/edit.js"

    $(document).on 'click', 'a.remove-document', ->
      document_id = $(this).data('document_id')
      del = confirm "Are you sure you want to delete this document?"
      if del
        if $(this).parent().siblings("td.viewed_at").text() == ""
          add_to_report_notification_count($(this).data('documentable_type'), -1)
        $.ajax
          type: 'DELETE'
          url: "/documents/#{document_id}.js"

  if $("body.documents-index").length > 0

    $(document).on 'click', '.report-buttons button', ->
      report_type = $(this).data("type")
      $.ajax
        type: 'GET'
        url: "/reports/new.js?report_type=#{report_type}"
        success: (data) ->
          add_to_report_notification_count('Identity', 1)

    $(document).on 'click', 'a.attached_file', ->
      update_view_on_download_new_report $(this), 'table.documents', 'Identity'

(exports ? this).update_view_on_download_new_report = (element, table_to_update, documentable_type) ->
  row_index = element.parents().eq(1).attr("data-index")

  date_downloaded_element = element.parent().siblings("td.viewed_at")
  
  if date_downloaded_element.text().length == 0
    add_to_report_notification_count(documentable_type, -1)
    
    utcdate = moment().format(I18n["documents"]["date_time_formatter_js"])
    
    $(table_to_update).bootstrapTable 'updateCell', 
      rowIndex: row_index
      fieldName: 'viewed_at'
      fieldValue: utcdate

(exports ? this).refreshDocumentsTables = ->
  $('#documents_table').bootstrapTable('refresh', {silent: "true"})
  $('#reports_table').bootstrapTable('refresh', {silent: "true"})
