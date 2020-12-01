# Copyright © 2011-2020 MUSC Foundation for Research Development~
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

module NotesHelper
  def edit_note_button(note, opts={})
    link_to icon('far', 'edit'), edit_note_path(note, note: { notable_id: note.notable_id, notable_type: note.notable_type }), remote: true, class: ['edit-note', opts[:button] ? 'btn btn-warning mr-1' : 'text-warning mr-2', note.identity_id == current_identity.id ? '' : 'disabled'], title: t('actions.edit'), data: { toggle: 'tooltip' }
  end

  def delete_note_button(note, opts={})
    link_to icon('fas', 'trash-alt'), note_path(note), method: :delete,  remote: true, class: ['delete-note', opts[:button] ? 'btn btn-danger' : 'text-danger', note.identity_id == current_identity.id ? '' : 'disabled'], title: t('actions.delete'), data: { toggle: 'tooltip', confirm_swal: 'true' }
  end

  def note_header(notable)
    header  = t('notes.header', notable_type: notable.try(:friendly_notable_type) || notable.model_name.human)
    header +=
      if notable.is_a?(LineItem)
        " " + content_tag(:small, "#{notable.service.name}", class: 'text-muted')
      else
        ""
      end

    raw(header)
  end

  def note_date(note)
    content_tag :small, class: 'text-muted mb-0' do
      if note.created_at == note.updated_at
        format_datetime(note.created_at, html: true)
      else
        raw(format_datetime(note.updated_at, html: true) + content_tag(:i, t('notes.edited'), class: 'ml-1'))
      end
    end
  end
end
