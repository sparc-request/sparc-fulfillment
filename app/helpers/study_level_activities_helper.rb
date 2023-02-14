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
  def notes(notes)
    bullet_point = notes.count > 1 ? "\u2022 " : ""
    notes.map{ |note| bullet_point + note.created_at.strftime('%m/%d/%Y') + ", " + note.comment + ", " + (note.identity_id ? Identity.find(note.identity_id).full_name : "System") }.join("<br>")
  end

  def documents(documents)
    bullet_point = documents.count > 1 ? "\u2022 " : ""
    documents.map{ |document| bullet_point + document.original_filename }.join("<br>")
  end

  def sla_docs_button(line_item)
    span = raw(content_tag(:span, line_item.documents.count, class: 'badge badge-light'))
    button = raw(content_tag(:button, raw(content_tag(:span, '', id: "line_item-#{line_item.id}")) + 'Documents ' + raw(span), type: 'button', class: 'btn btn-success button documents list', data: {'documentable-id' => line_item.id, 'documentable-type' => 'LineItem'}))

    button

    link_to documents_path(document: { documentable_id: line_item.id, documentable_type: LineItem.name }), remote: true, class: 'btn btn-sq btn-light position-relative' do
      raw(icon('far', 'file-alt fa-lg') + content_tag(:span, line_item.documents.count, class: ['badge badge-pill badge-c notification-badge', line_item.documents.count > 1 ? 'badge-warning ' : 'badge-secondary']))
    end
  end

  def sla_fulfillments_button(line_item)
    link_to fulfillments_path(line_item_id: line_item.id), remote: true, class: 'btn btn-sq btn-primary position-relative' do
      raw(icon('fas', 'list') + content_tag(:span, line_item.fulfillments.count, class: ['badge badge-pill badge-c notification-badge', line_item.fulfillments.count > 1 ? 'badge-warning ' : 'badge-secondary']))
    end
  end

  def sla_account_number(line_item)
    popover = render('study_level_activities/edit_form.html', line_item: line_item, field: :account_number)
    link_to 'javascript:void(0)', class: "edit-account_number-#{line_item.id}", data: { toggle: 'popover', content: popover, html: 'true', placement: 'top', trigger: 'manual' } do
      line_item.account_number.present? ? line_item.account_number : t('constants.na')
    end
  end

  def sla_contact(line_item)
    popover = render('study_level_activities/edit_form.html', line_item: line_item, field: :contact_name)
    link_to 'javascript:void(0)', class: "edit-contact_name-#{line_item.id}", data: { toggle: 'popover', content: popover, html: 'true', placement: 'top', trigger: 'manual' } do
      line_item.contact_name.present? ? line_item.contact_name : t('constants.na')
    end
  end

  def is_protocol_type_study?(protocol)
    protocol.protocol_type == 'Study'
  end

  def fulfillment_actions(fulfillment)
    notes_documents_array = [
      "<a class='fulfillment_notes' href='javascript:void(0)' title='Notes' data-notable-id='#{fulfillment.id}' data-notable-type='Fulfillment'>",
      "<i class='far fa-sticky-note'></i>",
      "</a>",
      "&nbsp&nbsp",
      "<a class='fulfillment_documents' href='javascript:void(0)' title='Documents' data-documentable-id='#{fulfillment.id}' data-documentable-type='Fulfillment'>",
      "<i class='far fa-file-alt'></i>",
      "</a>",
      "&nbsp&nbsp"]

    edit_delete_array = [
      "<a class='edit otf-fulfillment-edit ml10' href='javascript:void(0)' title='Edit' data-fulfillment_id='#{fulfillment.id}'>",
      "<i class='fas fa-edit'></i>",
      "</a>",
      "&nbsp&nbsp",
      "<a class='remove otf-fulfillment-delete' style='color:red' href='javascript:void(0)' title='Remove' data-fulfillment_id='#{fulfillment.id}'>",
      "<i class='far fa-trash-alt'></i>",
      "</a>"]

    unless (fulfillment.invoiced? || fulfillment.credited?)
      return (notes_documents_array + edit_delete_array).join ""
    else
      return notes_documents_array.join ""
    end
  end

  def billing_manager
    self.current_identity.billing_manager_protocols.include?(fulfillment.protocol)
  end

  def toggle_invoiced(fulfillment)
    if current_identity.billing_manager_protocols.include?(fulfillment.protocol)
      invoice_toggle_button(fulfillment)
    else
      invoice_read_only(fulfillment)
    end
  end

  def invoiced_date(fulfillment)
      date = [format_date(fulfillment.invoiced_date), "<br>",  "<a class='edit fulfillment-invoiced-date-edit ml10' href='javascript:void(0)' title='Edit Invoiced Date' data-fulfillment_id='#{fulfillment.id}'>",
      "<i class='fas fa-edit'></i>",
      "</a>"]

    if (current_identity.billing_manager_protocols.include?(fulfillment.protocol) && !fulfillment.credited? && fulfillment.invoiced?)
      return date.join""
    else
      format_date(fulfillment.invoiced_date)
    end
  end

  def toggle_credited(fulfillment)
    if current_identity.billing_manager_protocols_allow_credit.include?(fulfillment.protocol)
      credit_toggle_button(fulfillment)
    else
      credit_read_only(fulfillment)
    end
  end

  def invoice_read_only(fulfillment)
    (fulfillment.invoiced? ? t('constants.yes_select') : t('constants.no_select'))
  end

  def credit_read_only(fulfillment)
    (fulfillment.credited? ? t('constants.yes_select') : t('constants.no_select'))
  end

  def fulfillment_components_formatter(components)
    components.map(&:component).join(', ')
  end

  def fulfillment_date_formatter(fulfillment)
    if fulfillment.klok_entry_id.present? # this was imported from klok
      content_tag(:span, format_date(fulfillment.fulfilled_at), class: 'fulfillment-date-for-klok-entry') +
      content_tag(:i, '', class: 'far fa-clock')
    else
      format_date(fulfillment.fulfilled_at)
    end
  end

  def amount_fulfilled(line_item)
    line_item.fulfillments.sum(:quantity)
  end

  def month_year_formatter(fulfillment)
    fulfillment.fulfilled_at.strftime('%b %Y')
  end

  private

  def invoice_toggle_button(fulfillment)
    content_tag(:input, '', type: "checkbox", name: "invoiced", checked: fulfillment.invoiced?, data: {toggle: 'toggle', on: t('constants.yes_select'), off: t('constants.no_select'), id: fulfillment.id}, disabled: fulfillment.invoiced? || fulfillment.credited?, class: 'invoice_toggle')
  end

  def credit_toggle_button(fulfillment)
    content_tag(:input, '', type: "checkbox", name: "credited", checked: fulfillment.credited?, data: {toggle: 'toggle', on: t('constants.yes_select'), off: t('constants.no_select'), id: fulfillment.id}, disabled: fulfillment.credited? || fulfillment.invoiced?, class: 'credit_toggle')
  end

  def show_notification_badge(params, type)
    if type == 'notes' && params[:has_notes]
      raw(content_tag(:span, params[:object].notes.count, class:'notification orange-badge-notes'))
    elsif type == 'documents' && params[:has_documents]
      raw(content_tag(:span, params[:object].documents.count, class:'notification orange-badge-documents'))
    end
  end

end
