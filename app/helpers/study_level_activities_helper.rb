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

module StudyLevelActivitiesHelper
  def sla_docs_button(line_item)
    link_to documents_path(document: { documentable_id: line_item.id, documentable_type: LineItem.name }), remote: true, class: 'btn btn-sq btn-light position-relative' do
      raw(icon('far', 'file-alt fa-lg') + content_tag(:span, format_count(line_item.documents.length, 1), class: ['badge badge-pill badge-c notification-badge', line_item.documents.length > 1 ? 'badge-warning ' : 'badge-secondary']))
    end
  end

  def sla_fulfillments_button(line_item)
    link_to fulfillments_path(line_item_id: line_item.id), remote: true, class: 'btn btn-sq btn-primary position-relative' do
      raw(icon('fas', 'list') + content_tag(:span, format_count(line_item.fulfillments.length, 1), class: ['badge badge-pill badge-c notification-badge', line_item.fulfillments.length > 1 ? 'badge-warning ' : 'badge-secondary']))
    end
  end

  def sla_account_number(line_item)
    popover = render('study_level_activities/edit_form.html', line_item: line_item, field: :account_number)
    link_to line_item.account_number || t('constants.na'), 'javascript:void(0)', class: "edit-account_number-#{line_item.id}", data: { toggle: 'popover', content: popover, html: 'true', placement: 'top', trigger: 'manual' }
  end

  def sla_contact(line_item)
    popover = render('study_level_activities/edit_form.html', line_item: line_item, field: :contact_name)
    link_to line_item.contact_name || t('constants.na'), 'javascript:void(0)', class: "edit-contact_name-#{line_item.id}", data: { toggle: 'popover', content: popover, html: 'true', placement: 'top', trigger: 'manual' }
  end

  def sla_quantity_fulfilled(line_item)
    line_item.fulfillments.sum(&:quantity)
  end
end
