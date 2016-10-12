# Copyright © 2011-2016 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

module DocumentsHelper

  def format_document_date(date)
    if date.present?
      date.strftime(t(:documents)[:date_time_formatter_ruby])
    else
      ''
    end
  end

  def attached_file_formatter(document)
    case document.state
    when 'Completed'
      content_tag(:a, class: 'attached_file', id: "file_#{document.id}", href: document_path(document), target: :blank, title: 'Download File', 'data-id' => document.id) do
        content_tag(:span, '', class: 'glyphicon glyphicon-file')
      end
    when 'Processing'
      content_tag(:span, '', class: 'glyphicon glyphicon-refresh spin', style: 'cursor:auto')
    else
      content_tag(:span, '', class: 'glyphicon glyphicon-alert danger', style: 'cursor:auto')
    end
  end

  def edit_formatter(document)
    [
      "<a class='edit edit-document ml10' href='javascript:void(0)' title='Edit' data-document_id='#{document.id}'>",
      "<i class='glyphicon glyphicon-edit'></i>",
      "</a>"
    ].join ""
  end

  def delete_formatter(document)
    if document.completed? || document.failed?
    [
      "<a class='remove remove-document' href='javascript:void(0)' title='Remove' data-document_id='#{document.id}' data-documentable_type='#{document.documentable_type}'>",
      "<i class='glyphicon glyphicon-remove'></i>",
      "</a>"
    ].join ""
    else
      "<i class='glyphicon glyphicon-remove' style='cursor:default'></i>"
    end
  end
end
