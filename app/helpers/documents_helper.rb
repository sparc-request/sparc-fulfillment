module DocumentsHelper

  def attached_file_formatter(document)
    if document.completed?
      content_tag(:a, class: 'attached_file', href: document_path(document), title: 'Download File', document_id: document.id) do
        content_tag(:span, '', class: 'glyphicon glyphicon-file')
      end
    else
      content_tag(:span, '', class: 'glyphicon glyphicon-refresh spin', style: 'cursor:auto')
    end
  end

end
