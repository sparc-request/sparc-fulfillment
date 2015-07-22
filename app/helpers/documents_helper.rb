module DocumentsHelper

  def format_date(date)
    if date.present?
      date.strftime('%m/%d/%Y %H:%M:%S')
    else
      ''
    end
  end

  def attached_file_formatter(document)
    if document.completed?
      content_tag(:a, class: 'attached_file', href: document_path(document), target: :blank, title: 'Download File', 'data-id' => document.id) do
        content_tag(:span, '', class: 'glyphicon glyphicon-file')
      end
    else
      content_tag(:span, '', class: 'glyphicon glyphicon-refresh spin', style: 'cursor:auto')
    end
  end

  def edit_formatter(document)
    [
      "<a class='edit edit-document ml10' href='#' title='Edit' document_id='#{document.id}'>",
      "<i class='glyphicon glyphicon-edit'></i>",
      "</a>"
    ].join ""
  end

end
