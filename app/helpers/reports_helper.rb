module ReportsHelper

  def attached_file_formatter report
    if report.status == "Completed"
      [
        "<a class='attached_file' href='#{report.document.doc.url}' title='Download File' document_id='#{report.document.id}'>",
        "<i class='glyphicon glyphicon-file'></i>",
        "</a>"
      ].join ""
    else
      [
        "<i class='glyphicon glyphicon-refresh' style='cursor:auto;'></i>",
      ].join ""
    end
  end

end
