$ ->
    $(document).on 'click', '.edit-document', ->
      document_id = $(this).attr('document_id')
      $.ajax
        type: 'GET'
        url: "/documents/#{document_id}/edit"


  if $("body.documents-index").length > 0

    $(document).on 'click', '.report-buttons button', ->
      report_type = $(this).data("type")
      $.ajax
        type: 'GET'
        url: "/reports/new.js?report_type=#{report_type}"
        success: (data) ->
          $notification           = $('.notification.document-notifications')
          documents_notifications = parseInt $notification.text()

          $notification.text(documents_notifications + 1)
